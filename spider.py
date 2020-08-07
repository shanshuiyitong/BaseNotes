pyspider

https://www.cnblogs.com/hjnzs/p/12675504.html
https://www.cntofu.com/book/172/docs/1.md


Some basic knowledges you should know before scraping:

1.Web is a system of interlinked hypertext pages.
2.Pages is identified on the Web via uniform resource locator (URL).
3.Pages transferred via the Hypertext Transfer Protocol (HTTP).
4.Web Pages structured using HyperText Markup Language (HTML).

To scrape information from a web is

1.Finding URLs of the pages contain the information we want.
2.Fetching the pages via HTTP.
3.Extracting the information from HTML.
4.Finding more URL contains what we want, go back to 


#main > div > div.lister.list.detail.sub-list > div > div:nth-child(1) > div.lister-item-image.float-left > a

//*[@id="main"]/div/div[3]/div/div[1]/div[2]/a

API
self.crawl is the main interface to tell pyspider which url/url list should be crawled.


from pyspider.libs.base_handler import *


class Handler(BaseHandler):
    
    #为crawl api设置整个项目默认配置选项如header信息
    #priority, retries, exetime, age, itag, force_update, auto_recrawl, cancel
    crawl_config = {
    }
    
     #装饰器调度器默认参数，也可在crawl中定义，优先级更高
    @every(minutes=24 * 60)
    #整个程序的入口点，当点击界面run按钮时调用该方法。
    def on_start(self):
        ##crawl是最重要的API，将添加新任务，并通过该接口设置大多数参数
        self.crawl('http://scrapy.org/', callback=self.index_page)
        
    @config(age=10 * 24 * 60 * 60)
    
    #该方法获取一个response对象，
    #response.doc类似pyquery object可以抽取选择的元素的信息
    def index_page(self, response):
        for each in response.doc('a[href^="http"]').items():
            self.crawl(each.attr.href, callback=self.detail_page)
    
    #该方法可以覆盖，返回结果为字典对象
    @config(priority=2)
    def detail_page(self, response):
        return {
            "url": response.url,
            "title": response.doc('title').text(),
        }

架构：

下图显示了pyspider体系结构及其组件的概述以及系统内部发生的数据流的概述

组件通过消息队列连接，每个组件，包括消息队列运行着自己的进程或线程，并且可以替换。意味着，当处理变慢时，可以运行多实例，充分利用多个CPU，或者部署在多台机器上。

pyspider中的数据流如上图所示：

on_start当您按下RunWebUI上的按钮时，每个脚本都有一个名为callback的回调。将新任务on_start作为项目条目提交给Scheduler。

Scheduler将此on_start任务调度为数据URI作为Fetcher的常规任务。

Fetcher发出请求并对其做出响应（对于数据URI，这是一个虚假的请求和响应，但与其他正常任务没有区别），然后提供给处理器。

处理器调用该on_start方法并生成一些新的URL以进行爬网。处理器向Scheduler发送一条消息，告知此任务已完成，新任务通过消息队列发送到Scheduler（on_start在大多数情况下，这里没有结果。如果有结果，则处理器将它们发送给result_queue）。

调度程序接收新任务，在数据库中查找，确定任务是新的还是需要重新爬网，如果是，则将它们放入任务队列。按顺序发送任务。

这个过程重复（从第3步开始）并且在WWW死亡之前不会停止;-)。调度程序将检查定期任务以爬网最新数据。



webui界面使用




maskdown

段落的换行是使用两个以上空格加上回车。

另外区块是可以嵌套的，一个 > 符号是最外层，两个 > 符号是第一层嵌套
> 最外层
> > 第一层嵌套
> > > 第二层嵌套

这是一个链接 [菜鸟教程](https://www.runoob.com)




Seaborn 是一个基于 matplotlib 且数据结构与 pandas 统一的统计图制作库。
relplot()。这是一个figure-level的函数，可以用散点图和线图两种
特例：
scatterplot() (kind="scatter"; 默认值)
lineplot()(kind="line")
scatterplot()是relplot()中kind的默认类型，也可以通过kind="scatter"


由于lineplot()假设您想要将y绘制为x的函数，默认行为是在绘制之前按数字x对数据进行排序。但是，这可以被禁用：


df = pd.DataFrame(np.random.randn(500, 2).cumsum(axis=0), columns=["x", "y"])
sns.relplot(x="x", y="y", sort=False, kind="line", data=df);


核密度估计 ： KDE图
sns.distplot(x, hist=False, rug=True);

由给定样本集合求解随机变量的分布密度函数问题是概率统计学的基本问题之一。解决这一问题的方法包括参数估计和非参数估计

核密度估计（kernel density estimation）是在概率论中用来估计未知的密度函数，属于非参数检验方法之一

核密度就是用来估计密度的，如果你有一系列空间点数据，那么核密度估计往往是比较好的可视化方法


XPath 术语 ：xml格式路径表达式path

有七种类型的节点：元素、属性、文本、命名空间、处理指令、注释以及文档（根）节点
看做一棵树：根节点称为文档节点

<?xml version="1.0" encoding="ISO-8859-1"?>

<bookstore>  #文档节点
    <book>
      <title lang="en">Harry Potter</title>  #lang="en"属性节点
      <author>J K. Rowling</author>    #元素节点
      <year>2005</year>
      <price>29.99</price>
    </book>
</bookstore>


基本值是无父或无子的节点：如J K. Rowling、en

节点关系：
每个元素以及属性都有一个父

先辈节点-->父节点-->子节点（平行 同胞）-->后代

nodename	选取此节点的所有子节点。
/	从根节点选取。
//	从匹配选择的当前节点选择文档中的节点，而不考虑它们的位置。
.	选取当前节点。
..	选取当前节点的父节点。
@	选取属性。
====》
bookstore	选取 bookstore 元素的所有子节点。
/bookstore	选取根元素 bookstore。
bookstore/book	选取属于 bookstore 的子元素的所有 book 元素。
//book	选取所有 book 子元素，而不管它们在文档中的位置。
bookstore//book	选择属于 bookstore 元素的后代的所有 book 元素，而不管它们位于 bookstore 之下的什么位置。
//@lang	选取名为 lang 的所有属性。

*通配符匹配所有

/bookstore/*	选取 bookstore 元素的所有子元素。
//*	选取文档中的所有元素。
//title[@*]	选取所有带有属性的 title 元素。

通过在路径表达式中使用“|”运算符，您可以选取若干个路径

选取第一个 book 的 title，last()-1/
/bookstore/book[1]/title
/bookstore/book[price>35]/title

下面的例子选取 price 节点中的所有文本
/bookstore/book/price/text()


c = np.array([[(1.5,2,3), (4,5,6)], [(3,2,1), (4,5,6)]],
dtype = float)



https://www.qiushibaike.com/8hr/page/3/

fetch_type='js'

def __init__(self):
        self.base_url = 'https://www.qiushibaike.com/8hr/page/'
        self.page_num = 1
        self.total_num = 30
def on_start(self):
    while self.page_num <= self.total_num:
        url = self.base_url + str(self.page_num)
        print url
        self.crawl(url, callback=self.index_page)
        self.page_num += 1




























