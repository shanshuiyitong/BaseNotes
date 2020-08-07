import paramiko
from paramiko.ssh_exception import NoValidConnectionsError 
from paramiko.ssh_exception import AuthenticationException 
import time
import random


#基于密码或公钥远程连接
#usage: 
#   connect('uname','hostname', port,'username','passwd')
#   connect('uname','hostname', port,'username',id_rsa=True)

def conn_policy(id_rsa=False):
    if id_rsa = True:
        private_key = paramiko.RSAKey.from_private_key_file('id_rsa')
    else:
        private_key=None
    return private_key

def connect(cmd,hostname,port=22,username='root',passwd=None,id_rsa=False):  
    client = paramiko.SSHClient() 
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    private_key=conn_policy()
    try: 
        client.connect(hostname=hostname, 
        portport=port, 
        username=username, 
        password=passwd,
        pkey=private_key) 
        print('正在连接主机%s......'%(hostname)) 
    except NoValidConnectionsError as e: ###用户不存在时的报错 
        print("连接失败") 
    except AuthenticationException as t: ##密码错误的报错 
        print('密码错误') 
    else: 
 #4.执行操作 
        stdin,stdout, stderr = client.exec_command(cmd) 
        #5.获取命令执行的结果 
        result=stdout.read().decode('utf-8') 
        print(result) 
 #6.关闭连接 
    finally: 
        client.close() 

#如批量主机执行命令
#with open('ip.txt') as f: #ip.txt为本地局域网内的一些用户信息 
#   for line in f: 
#        lineline = line.strip() ##去掉换行符 
#       hostname,port,username,passwd= line.split(':') 
#       print(hostname.center(50,'*')) 
#       connect('uname','hostname', port,'username','passwd')   


#上传下载文件
def put_getFile(ip,user,password,localpath,remotepath)
    private_key = paramiko.RSAKey.from_private_key_file('id_rsa') 
    tran = paramiko.Transport('172.25.254.31',22) 
    tran.connect(username='root',password='westos') 
    #获取SFTP实例 
    sftp = paramiko.SFTPClient.from_transport(tran) 
    remotepath='/home/kiosk/Desktop/fish8' 
    localpath='/home/kiosk/Desktop/fish1' 
    sftp.put(localpath,remotepath) 
    sftp.get(remotepath, localpath) 


#字符串统计 

def chrWordCount(str1,delimter=" "):
    chr_dict1={}
    for chr1 in str1:
        if chr1 != " ":
            if char1 in chr_dict1:
                chr_dict1[char1] += 1
            else:
                chr_dict1[char1] = 1
    return str(chr_dict1).strip("{""}").replace("'","")      


#""" 计算一个文件大致包含多少个单词 """
#注.read()读取文件不宜过大导致内存溢出

def count_words(filename): 
    try:
        with open(filename) as f_obj:
            contents = f_obj.read()
    except FileNotFoundError:
        msg = "Sorry, the file " + filename + " does not exist."
        print(msg)
    else:
    # 计算文件大致包含多少个单词
        words = contents.split()
        num_words = len(words)
        print("The file " + filename + " has about " + str(num_words) +" words.")
#usage ：
#   filenames = ['alice.txt', 'siddhartha.txt', 'moby_dick.txt', 'little_women.txt']
#   for filename in filenames:
#   count_words(filename)


#打印出三角形
#usage：t=Triangle(10)
class Triangle(object):
    def __init__(self,num):

        for i in range(1,num):
            self.s=""
            for j in range(0,num-i):
                self.s+=" "
            for k in range(0,2*i-1):
                self.s+="*"
            print(self.s)

#秒表计时

class Timer(object):
    def __init__(self):        
        print('按下回车开始计时，按下 Ctrl + C 停止计时。')
        while True:
            try:
                input()
                starttime = time.time()
                print('开始')
                while True:
                    print('计时: ', round(time.time() - starttime, 0),'秒')
                    time.sleep(1)
            except KeyboardInterrupt:
                print('结束')
                endtime = time.time()
                print('总共的时间为:', round(endtime - starttime, 2), 'secs')
                break

# 功能随机码
# checkcode导入random模块
# 定义一个保存验证码的变量，for循环实现重复4次的循环在这个循环，
# 调用random模块提供的random.range(),randian()生成符合要求的验证码# a~z 97-122，A~Z ：65~90,1~9

def randomcode():
    code=''
    for i in range(5):
        index=random.randint(0,5)
        if index != i and index+1 != i:
            code+=chr(random.randint(97,120))
        elif index+1==i:
            code+=chr(random.randrange(65,90))
        else:
            code+=str(random.randint(1,10))
    return code

#面向过程：根据业务逻辑从上到下写代码
#面向对象：将数据与函数绑定到一起，分类进行封装，每个程序员只要负责分配
#给自己的分类，这样能够更快速的开发程序，减少了重复代码



#spark sql ops:5种形式操作 DF 、SQL

1 df.select("name").show()

2 df.select($"name", $"age" + 1).show()
  df.filter($"age" > 21).show()


3 df.select(col("name"), col("age").plus(1)).show(); 

4 df.select(df['name'], df['age'] + 1).show()

5 val sqlDF = spark.sql("SELECT * FROM people")


