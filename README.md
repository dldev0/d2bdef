# D2BDEF

数据库备份脚本

by nbsp@outlook.com

d2bdef = Database + Backup + def

其中的def是作者标记

------

## 功能介绍


+ 备份自定义配置的内容
+ 备份成功后发送邮件通知且生成备份日志
+ 配置内容暂只支持mysql


----

### 脚本结构

1.  init.sh  主程序

1.  init.conf  程序配置

1.  comm.func  公用函数

1.  db.conf  需备份数据库配置

1.  mail.conf  邮件接受人列表

1.  mysql.func MYSQL函数

1.  comm.func  公用函数

1.  db.conf  需备份数据库配置

1.  mail.conf  邮件接受人列表

1.  mysql.func MYSQL函数

1.  run.log  脚本日志

1.  README.md  关于


### db.conf

#### 功能

记录需备份库的详细信息

#### 配置文件规则

  数据库类型| 用户名|密码|主机:端口 | 库名:表1,表2...     |备份路径  |备份周期|过期时间|字符编码

  db    | user|passwd|host:port | dbname:table1,table2|backupPath|  week  |expire|charset

  * 该配置暂不能有空格


  * 如若想备份库除了某些表在dbname前面加!如下

  db    | user|passwd|host:port |!dbname:table1,table2|backupPath|  week  |expire

### init.conf

#### 功能

脚本的主要配置，默认配置都在这个文件里面

----

## 使用指南

### 配置脚本跟路径

init.sh 配置 base变量的根路径地址

  + 邮件发送策略

  + 默认备份路径

  + 备份过期时间

  + 执行文件路径

### 配置数据库信息

db.conf 配置需要备份的库或表的信息

### 任务计划执行脚本

crontab或其他任务计划程序执行脚本即可
