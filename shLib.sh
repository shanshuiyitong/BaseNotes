############################################################# 功能函数 Begin ##################################################################

        #显示消息
        #showType='errSysMsg/errSys/errUserMsg/warning/msg/msg2/OK'
        #错误输出（以红色字体输出） errSysMsg：捕捉系统错误后发现相信并退出；errSys：捕捉到系统错误后退出；errUserMsg：自定义错误并退出，但不退出（errSysMsg及errUserMsg可以赋第三个参数isExit为非1来控制不退出）
        #警告（以黄色字体输出）  warning：显示warning，但不退出
        #显示信息（以白色字体输出，OK以绿色输出） msg：输出信息并换行；msg2：输出信息不换行；OK：输出绿色OK并换行
        function showMsg()
        {
                errState="$?"
                local showType="$1"
                local showContent="$2"
                local isExit="$3"
                #如果isExit为空，则默认出错时该退出
                if [ "${isExit}" = "" ]; then
                        isExit=1
                fi
                local isIP=`echo ${mysqlHost} | grep -E "172|192|10" | wc -l`
                if [ "${mysqlHost}" = "localhost" ]; then
                        local showExtent="localhost.${siteId}"
                elif [ "${isIP}" -eq "1" ]; then
                        local showExtent="db1(${mysqlHost}).${siteId}"
                else
                        showExtent=''
                fi
                showType=`echo ${showType} | tr 'A-Z' 'a-z'`
                case "${showType}" in
                        errsysmsg)
                                if [ "${errState}" -ne 0 ]; then
                                        echo -e "\033[31;49;1m[`date +%F' '%T`] ${showExtent} Error: ${showContent}\033[39;49;0m" | tee -a ${logFile}
                                        echo -e "\033[31;49;1m[`date +%F' '%T`] Call Relation: bash${pid}\033[39;49;0m" | tee -a ${logFile}
                                        if [ "${isExit}" -eq 1 ]; then
                                                exit 1
                                        fi
                                fi
                        ;;
                        errsys)
                                if [ "$errState" -ne 0 ]; then
                                        exit 1
                                fi
                        ;;
                        errusermsg)
                                echo -e "\033[31;49;1m[`date +%F' '%T`] ${showExtent} Error: ${showContent}\033[39;49;0m"  | tee -a ${logFile}
                                echo -e "\033[31;49;1m[`date +%F' '%T`] Call Relation: bash${pid}\033[39;49;0m" | tee -a ${logFile}
                                if [ "${isExit}" -eq 1 ]; then
                                        exit 1
                                fi
                        ;;
                        warning)
                                echo -e "\033[33;49;1m[`date +%F' '%T`] ${showExtent} Warnning: ${showContent}\033[39;49;0m"  | tee -a ${logFile}
                                echo -e "\033[33;49;1m[`date +%F' '%T`] Call Relation: bash${pid}\033[39;49;0m"  | tee -a ${logFile}
                        ;;
                        msg)
                                echo "[`date +%F' '%T`] ${showExtent} ${showContent}" | tee -a ${logFile}
                        ;;
                        msg2)
                                echo -n "[`date +%F' '%T`] ${showExtent} ${showContent}" | tee -a ${logFile}
                        ;;
                        ok)
                                echo "OK" >> ${logFile}
                                echo -e "\033[32;49;1mOK\033[39;49;0m" 
                        ;;
                        *)
                                echo -e "\033[31;49;1m[`date +%F' '%T`] Error: Call founction showMsg error\033[39;49;0m"  | tee -a ${logFile}
                                exit 1
                        ;;
                esac
        }

        #执行sql语句
        # echo "select now()" | executeSql root 7roaddba
        function executeSql()
        {
                local sql="$1"
                if [ -z "$mysqlUser" -o "$mysqlUser" = "" -o -z "${mysqlPwd}" -o "${mysqlPwd}" = "" ]; then
                        showMsg "errUserMsg" "mysql user or mysql password is not vaild."
                fi
                if [ "$sql" = "" ]
                then
                        showMsg "errUserMsg" "sql statement is null "
                else
                        echo -e "$sql" | /usr/local/mysql/bin/mysql -h${mysqlHost} -u${mysqlUser} -p${mysqlPwd} $useDBName --default-character-set=utf8 -N 
                fi
        }

        #版本检查
        function versionCheck()
        {
                #softFtpURL="$1"
                #softFtpURLMirror="$2"
                #httpUser="$3"
                #httpPwd="$4"
                prjKeyWord="$1"
                softWareName=$(basename $0)
                rm -f dbToolsVersion.txt.wgetTemp
                verFullURL=$(echo "${softFtpURL}/dbToolsVersion.txt"| sed 's/http:\/\//http:##/g' | sed 's/\/\//\//g' | sed 's/http:##/http:\/\//')
                wget --http-user=${httpUser} --http-password=${httpPwd} -t 2 -T 5 "${verFullURL}" -O dbToolsVersion.txt.wgetTemp >> ${logFile} 2>&1
                if [ "$?" -ne 0 ]; then
                        softFtpURL="${softFtpURLMirror}"
                        verFullURL2=$(echo "${softFtpURL}/dbToolsVersion.txt"| sed 's/http:\/\//http:##/g' | sed 's/\/\//\//g' | sed 's/http:##/http:\/\//')
                        wget --http-user=${httpUser} --http-password=${httpPwd} -t 2 -T 5 "${verFullURL2}" >> ${logFile} 2>&1
                        showMsg "errSysMsg" "Can not connect to version server from '${verFullURL}' and '${verFullURL2}'"
                fi
                version=`md5sum ${softWareName} | awk '{print $1}'`
                if [ ! -f dbToolsVersion.txt.wgetTemp ]; then
                        showMsg "errUserMsg" "Can not found the version file."
                fi
                theServerVer=`cat dbToolsVersion.txt.wgetTemp | dos2unix | grep "${prjKeyWord}" | grep "${softWareName}$" | awk '{print $1}'`
                if [ "${theServerVer}" != "${version}" ]; then
                        rm -rf ${softWareName}.tmp
                        showMsg "msg2" "This software has expired, now try to upgrade......."
                        thePath=$(cat dbToolsVersion.txt.wgetTemp | grep "\ ${prjKeyWord}" | grep "${softWareName}" | awk '{print $NF}')
                        softFullURL=$(echo "${softFtpURL}/${thePath}" | sed 's/http:\/\//http:##/g' | sed 's/\/\//\//g' | sed 's/http:##/http:\/\//')
                        wget --http-user=${httpUser} --http-password=${httpPwd} "${softFullURL}" -O ${softWareName}.wgetTmp >> ${logFile} 2>&1
                        if [ "$?" -ne 0 ]; then
                                showMsg "msg" "Local md5: ${version}  Server md5: ${theServerVer}"
                                showMsg "errUserMsg" "Upgrade fail, please connect with DBA."
                        else 
                                mv ${softWareName}.wgetTmp ${softWareName} -f
                                chmod +x ${softWareName}
                                showMsg "OK"
                                showMsg "errUserMsg" "Please run this software again."
                        fi
                fi
                rm -rf dbToolsVersion.txt.wgetTemp
        }

        #下载文件，如果文件存在，则判断Md5，不一致则重新下载，否则直接下载
        #softFtpURL='http://113.107.88.124:8088/shenqu'         #主站http
        #softFtpURLMirror='http://113.107.167.90:8088/shenqu'   #镜像http
        #httpUser='7roadwget'
        #httpPwd='love7road'
        #fileDownload 'aaa.txt' 'opendb'
        function fileDownload()
        {
                #softFtpURL="$1"
                #softFtpURLMirror="$2"
                #httpUser="$3"
                #httpPwd="$4"
                theDownFileName="$1"
                prjKeyWord="$2"
                URLType='primary station'
                rm -f dbToolsVersion.txt.wgetTemp
                verFullURL=$(echo "${softFtpURL}/dbToolsVersion.txt"| sed 's/http:\/\//http:##/g' | sed 's/\/\//\//g' | sed 's/http:##/http:\/\//')
                wget --http-user=${httpUser} --http-password=${httpPwd} -t 2 -T 5 "${verFullURL}" -O dbToolsVersion.txt.wgetTemp >> ${logFile} 2>&1
                if [ "$?" -ne 0 ]; then
                        softFtpURL="${softFtpURLMirror}"
                        URLType='mirror station'
                        verFullURL2=$(echo "${softFtpURL}/dbToolsVersion.txt"| sed 's/http:\/\//http:##/g' | sed 's/\/\//\//g' | sed 's/http:##/http:\/\//')
                        wget --http-user=${httpUser} --http-password=${httpPwd} -t 2 -T 5 "${verFullURL2}"  -O dbToolsVersion.txt.wgetTemp >> ${logFile} 2>&1
                        showMsg "errSysMsg" "Can not download the version file from '${verFullURL}' and '${verFullURL2}'"
                fi
                thePath=$(cat dbToolsVersion.txt.wgetTemp | grep "\ ${prjKeyWord}" | grep "${theDownFileName}$" | awk '{print $NF}')
                softFullURL=$(echo "${softFtpURL}/${thePath}" | sed 's/http:\/\//http:##/g' | sed 's/\/\//\//g' | sed 's/http:##/http:\/\//')
                if [ -f ${theDownFileName} ]; then
                        theLocalMd5=`md5sum ${theDownFileName} | awk '{print $1}'`
                        theFileMd5=`cat dbToolsVersion.txt.wgetTemp | dos2unix | grep "\ ${prjKeyWord}" |  grep "${theDownFileName}$" | awk '{print $1}'`
                        if [ "${theLocalMd5}" != "${theFileMd5}" ]; then
                                rm -f ${theDownFileName}.wgetTmp
                                showMsg "msg2" "Download file ${theDownFileName} from ${URLType}......"
                                wget --http-user=${httpUser} --http-password=${httpPwd} "${softFullURL}" -O ${theDownFileName}.wgetTmp >> ${logFile} 2>&1
                                showMsg "errSysMsg" "Some error occur when 'wget \"${softFullURL}\"'"
                                showMsg "OK"
                                mv  ${theDownFileName}.wgetTmp ${theDownFileName} -f
                        fi
                else
                        rm -f ${theDownFileName}.wgetTmp
                        showMsg "msg2" "Download file ${theDownFileName} from ${URLType}......"
                        wget --http-user=${httpUser} --http-password=${httpPwd} "${softFullURL}" -O ${theDownFileName}.wgetTmp >> ${logFile} 2>&1
                        showMsg "errSysMsg" "Some error occur when 'wget \"${softFullURL}\"'"
                        showMsg "OK"
                        mv  ${theDownFileName}.wgetTmp ${theDownFileName} -f
                fi
                #检查最新下载的文件MD5是否正确
                theLocalMd5=`md5sum ${theDownFileName} | awk '{print $1}'`
                theFileMd5=`cat dbToolsVersion.txt.wgetTemp | dos2unix | grep "\ ${prjKeyWord}" |  grep "${theDownFileName}$" | awk '{print $1}'`
                if [ "${theLocalMd5}" != "${theFileMd5}" ]; then
                        showMsg "errUserMsg" "The MD5 of new download file '${theDownFileName}' is error. theLocalMd5=${theLocalMd5}, theServerMd5=${theFileMd5}"
                fi
                rm -f dbToolsVersion.txt.wgetTemp
        }


        #切换mysql信息
        function setMysqlInfo()
        {
                dbType="$1"
                if [ "${dbType}" = "master" ]; then
                        mysqlUser=${masterUser}
                        mysqlPwd=${masterPwd}
                        mysqlHost=${master_inner_ip}
                elif [ "${dbType}" = "slave" ]; then
                        mysqlUser=${slaveUser}
                        mysqlPwd=${slavePwd}
                        mysqlHost='localhost'
                else
                        showMsg "errUserMsg" "Can no judge the dbType '${dbType}' on function setMysqlInfo"
                fi
        }

        #复制一个或多个文件
        #autoScp 'a.txt b.txt c.txt' 'IP' '端口' '账户' '密码' '/root'
        #autoScp 'a b c' '10.10.1.122' 22 root love7road '/root'
        function autoScp()
        {
                SRC_FILENAME="$1"
                #SRC_HOST="$2"
                #SRC_PORT="$3"
                #SRC_USER="$4"
                #SRC_PWD="$5"
                SRC_PATH="$2"
                errBreak="$3"
                expect -c "
                        set timeout 300
                        spawn scp -P $SRC_PORT ${SRC_FILENAME} $SRC_USER@$SRC_HOST:$SRC_PATH
                        expect {
                                  \"(yes/no)?\"    {send \"yes\r\";exp_continue}
                                  \"password: \"   {send \"$SRC_PWD\r\";exp_continue}
                                  \"FATAL\" {exit 1;exp_continue}
                                  timeout {exit 2;exp_continue}
                                  \"No route to host\" {exit 3;exp_continue}
                                  \"Connection Refused\" {exit 4;exp_continue}
                                  \"Host key verification failed\" {exit 5;exp_continue}
                                  \"Illegal host key\" {exit 6;exp_continue}
                                  \"Connection Timed Out\" {exit 7;exp_continue}
                                  \"Connection timed out\" {exit 8;exp_continue}
                                  \"Disconnected; connection lost\" {exit 9;exp_continue}
                                  \"Authentication failed\" {exit 10;exp_continue}
                                  \"Destination Unreachable\" {exit 11;exp_continue}
                                  \"No such file\" {exit 12}
                               }
                "
                errorNum="$?"
                if [ "${errBreak}" = "0" ]; then
                        if [ "${errorNum}" -ne 0 ]; then
                                echo "autoScp errNo: ${errorNum}" | tee -a ${logFile}
                                return 1
                        fi
                else
                        if [ "${errorNum}" -ne 0 ]; then
                                echo "autoScp errNo: ${errorNum}" | tee -a ${logFile}
                                showMsg "errSysMsg" "Some error occur when execute 'scp -P $SRC_PORT ${SRC_FILENAME} $SRC_USER@$SRC_HOST:$SRC_PATH'"
                        fi
                fi
        }

        #在远程执行指定命令（必须先初始化 $SRC_HOST $SRC_PORT $SRC_PWD 三个变量）
        #autossh 'ls'           #出错后退出
        #autossh 'ls' '0'       #出错后不退出（执行return）
        function autossh()
        {
                #SRC_HOST="$1"
                #SRC_PORT="$2"
                #SRC_PWD="$3"
                commands="$1"
                errBreak="$2"
                expect -c "
                        set timeout 300
                        spawn  ssh -p $SRC_PORT $SRC_HOST \"$commands\"
                        expect {
                                  \"(yes/no)?\"                         {send \"yes\r\";exp_continue}
                                  \"password:\"                         {send \"${SRC_PWD}\r\";exp_continue}
                                  \"FATAL\"                             {exit 1;exp_continue}
                                  timeout                               {exit 2;exp_continue}
                                  \"No route to host\"                  {exit 3;exp_continue}
                                  \"Connection Refused\"                {exit 4;exp_continue}
                                  \"Connection refused\"                {exit 5;exp_continue}
                                  \"Host key verification failed\"      {exit 6;exp_continue}
                                  \"Illegal host key\"                  {exit 7;exp_continue}
                                  \"Connection Timed Out\"              {exit 8;exp_continue}
                                  \"Connection timed out\"              {exit 9;exp_continue}
                                  \"Interrupted system call\"           {exit 10;exp_continue}
                                  \"Disconnected; connection lost\"     {exit 11;exp_continue}
                                  \"Authentication failed\"             {exit 12;exp_continue}
                                  \"File exists\"                       {exit 13;exp_continue}
                                  \" Error: \"                          {exit 14;exp_continue}
                                  \" ERROR: \"                          {exit 15;exp_continue}
                                  \" error \"                           {exit 16;exp_continue}
                                  \" denied \"                          {exit 17;exp_continue}
                                  \"No such file\"                      {exit 18;exp_continue}
                                  \"Destination Unreachable\"           {exit 19}
                               }
                "
                errorNum="$?"
                if [ "${errBreak}" = "0" ]; then
                        if [ "${errorNum}" -ne 0 ]; then
                                echo "autossh errNo: ${errorNum}" | tee -a ${logFile}
                                return 1
                        fi
                else
                        if [ "${errorNum}" -ne 0 ]; then
                                echo "autossh errNo: ${errorNum}" | tee -a ${logFile}
                                showMsg "errUserMsg" "Some error occur when autoRun '${commands}' on ${SRC_HOST}"
                        fi
                fi
        }

        #取得本机的内网IP
        function getLocalInnerIP()
        {
                isEth=`ifconfig | grep -w eth1 | wc -l`
                if [ "${isEth}" -eq 0 ]; then
                        netCar=em2
                else
                        netCar=eth1
                fi
                ifconfig ${netCar} | grep -o 'inet addr:[0-9.]*' | grep -o '[0-9.]*$'
        }

        #取得本机的外网IP
        function getLocalOuterIP()
        {
                isEth=`ifconfig | grep -w eth0 | wc -l`
                if [ "${isEth}" -eq 0 ]; then
                        netCar=em1
                else
                        netCar=eth0
                fi
                ifconfig ${netCar} | grep -o 'inet addr:[0-9.]*' | grep -o '[0-9.]*$'
        }

        #检查指定文件是否存在
        function checkFileExist()
        {
                theFileName="$1"
                if [ ! -f $theFileName ]; then
                        showMsg "errUserMsg" "The file '$theFileName' is not exist."
                fi
        }

        #检查变量是否存在
        function checkVar()
        {
                local theVar="$1"
                if [ "${theVar}" = "" ]; then
                        showMsg "errUserMsg" "The var is not invalidation."
                fi
        }

        #检查软件是否已安装
        function checkSoftInstall()
        {
                softName="$1"
                which ${softName} &> /dev/null 
                showMsg "errSysMsg" "The software '${softName}' is not install."
        }

        #解密
        function strDecoding()
        {
                encryptCode="$1"
                theCode=`echo ${encryptCode} | sed 's/ME~we/y/g' | sed 's/k8i2UP/x/g' | sed 's/\Ya;q46/w/g' | sed 's/uqcM23/u/g' | sed 's/HA@d/o/g' | sed 's/43w,cv/m/g' | sed 's/(6d:ad/j/g' | sed 's/_iy%wt/b/g' | sed 's/hmdf8d/a/g' | sed 's/gfLNmd/Y/g' |sed 's/o;th}d/W/g' | sed 's/Y82dKH/U/g' | sed 's/q2I%Rr/N/g' | sed 's/Nqdlpd/L/g' | sed 's/@GH(hg/H/g' | sed 's/vTDD)m/D/g' | sed 's/+pH@de/C/g' | sed 's/MHzuvm/A/g' | base64 -d -i`
                theLen=${#theCode}
                i=0
                strHead=''
                strTail=''
                while [ "${i}" -lt "${theLen}" ]; do
                        theStr="${theCode:$i:1}"
                        isOdd=`expr ${i} % 2`
                        if [ "${isOdd}" -eq 1 ]; then
                                strHead="${strHead}${theStr}"
                        else
                                strTail="${theStr}${strTail}"
                        fi
                        i=`expr $i + 1`
                done
                echo "${strHead}${strTail}"
        }

         #解析参数
        function operate() {
                if [ "$1" = "" -a "$2" = "" -a "$3" = "" ]; then
                        #用法函数
                        my_usage
                        exit 1
                fi
                #unset OPTIND
                while getopts :t: opt; do
                        case "$opt" in
                        t)
                                echo "111"
                                ;;
                        :)      
                                echo "$0: must supply an argument to -${OPTARG}." >&2
                                my_usage
                                exit 1
                                ;;
                        \?)     
                                echo "invalid option -$OPTARG ignored." >&2
                                my_usage
                                exit 1
                                ;;
                        *)
                                echo 'unknown option'
                                my_usage
                                exit 1
                                ;;
                        esac
                done
        }


        #并发执行
        # execConcurrency 并发进程个数 '命令1' '命令2' '命令3' ...
        # execConcurrency 2 'sleep 3;echo yes' 'sleep 5;echo no'
        function execConcurrency() 
        {
                #并发数据量
                local thread=$1
                #并发命令
                local cmd=$2
                #定义管道，用于控制并发线程
                tmp_fifofile="/tmp/$$.fifo"
                mkfifo $tmp_fifofile
                #输入输出重定向到文件描述符6
                exec 6<>$tmp_fifofile
                rm -f $tmp_fifofile
                #向管道压入指定数据的空格
                for ((i=0;i<$thread;i++)); do
                        echo
                done >&6
                #遍历命令列表
                while [ "$cmd" ]; do
                        #从管道取出一个空格（如无空格则阻塞，达到控制并发的目的）
                        read -u6
                        #命令执行完后压回一个空格
                        { eval $2;echo >&6; } & #> /dev/null 2>&1 &
                        shift
                        cmd=$2
                done
                #等待所有的后台子进程结束
                wait
                #关闭df6
                exec 6>&-
        }

        #进度条
        #processBar 总完成数 目前完成数
        #示例：
        #i=0
        #    printf "\n"
        #    while [ $i -le 100 ]; do
        #          processBar 100 "$i"
        #          sleep 0.05
        #          i=`expr $i + 1`
        #    done
        #    printf "\n"
        function processBar()
        {
                allCount="$1"
                nowCount="$2"
                tput sc
                #隐藏光标
                tput civis
                #取得当前屏幕的列和行数
                screenCols=`tput cols`
                screenLines=`tput lines`
                #取得当前所在的行
                echo -ne '\e[6n';read -sdR pos
                pos=${pos#*[}
                nowLine=`echo ${pos} | cut -d ';' -f 1`
                if [ "${screenLines}" -ne "${nowLine}" ]; then
                        nowLine=`expr ${nowLine} - 1`
                fi
                #算出进度条的块数
                allBlock=`echo "${screenCols}-7" | bc`
                #算出目前完成的块数
                nowBlock=`echo "(${nowCount}*${allBlock}/${allCount})" | bc`
                #算出总比例
                finishRate=`echo "${nowCount}*100/${allCount}" | bc`
                ratePos=`expr ${allBlock} + 2`
                #如果当前光标在底部，先空两行，留出来给显示
                if [ "${isFirst}" = "" -a "${screenLines}" -eq "${nowLine}" ]; then
                        printf "\n"
                        nowLine=`expr ${nowLine} - 2`
                        isFirst='no'
                elif [ "${screenLines}" -eq "${nowLine}" ]; then
                        nowLine=`expr ${nowLine} - 2`
                fi
                #找准位置显示完成数
                tput cup ${nowLine} 0
                printf "Finish Process: ${nowCount}/${allCount}"
                #显示进度条
                nowLine=`expr ${nowLine} + 1`
                tput cup ${nowLine} 0
                printf "["
                printf -v line '%*s' "$nowBlock"
                echo -n ${line// /=}
                printf ">"
                tput cup ${nowLine} ${ratePos}
                printf "]%d%%" ${finishRate}
                if [ "${nowCount}" -eq "${allCount}" ]; then
                        printf "\n"
                        #显示光标
                        tput cnorm
                else
                        tput rc
                fi
        }

        #判断主从是否同步
        function checkSlave()
        {
                isSlaveOK=`echo "show slave status\G;" | executeSql | grep -E 'Slave_IO_Running|Slave_SQL_Running' | grep 'Yes' | wc -l`
                if [ ${isSlaveOK} -ne 2 ]; then
                        showMsg "errusermsg" "Slave is stop"
                fi
        }

############################################################# 功能函数 End ####################################################################

#初始化
function init()
{
        sid=`basename $0`
        export pid="${pid}-->$sid"
        theFiledir=`echo $(cd "$(dirname "$0")"; pwd)`
        cd ${theFiledir}
        logFile='/data/shelllog/XXX.log'
}
