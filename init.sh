#!/bin/bash
#
#
#      数据库备份脚本
#
#	by nbsp@outlook.com
#
#       v1.0 2014.02.23 
#
#	基本功能完成，日志、邮件通知功能待添加
#
#       v1.1 2014.02.24
#
#	Add db.conf数据库用户名密码分隔符改成"|"避免密码中包含有分隔符
#	Add comm.func过期文件删除、日志功能完成
#
#       v1.2 2014.02.25
#	Add 日志、邮件功能完成
#	Add 添加排除表备份功能
#
#       v1.3 2014.02.26
#	Fix init.sh的部分错误
#	Fix 备份路径每个库一个文件夹
#	Fix 邮件内容、发送逻辑优化
#
#       v1.4 2014.02.27
#	Fix 改变排除表备份方式由原执行show tables脚本方式
#	    变为添加参数 --ignore-table=db.tab
#	Fix 修复过期文件删除问题
#
#       v1.5 2014.03.03
#	Add db.conf增加字符编码栏
#
#

#结束脚本

die()

{

echo >&2 " :(  $@"

exit 1

}


#脚本根路径

base=/usr/local/d2bdef

[ ! -d "$base" ] && die "NOT FOUND $base"

#启动检测项

[ ! -f "${base}/init.conf" ] && die "NOT FOUND ${base}/init.conf" 

[ ! -f "${base}/comm.func" ] && die "NOT FOUND ${base}/comm.func" 

[ ! -f "${base}/mysql.func" ] && die "NOT FOUND ${base}/mysql.func" 

#导入配置

. "${base}/init.conf"

. "${base}/comm.func"

. "${base}/mysql.func"

[ ! -f "$db" ] && die "NOT FOUND ${db}" 

[ ! -f "$mail_file" ] && die "NOT FOUND ${mail_file}" 

[ ! -f "$log_file" ] && touch $log_file

log "start"

#解析文档
#去除注释、空行、转义字符

db_pase()

{
	f=$1

#while START

while read l ;do

#del"#" START

	if [ "${l:0:1}" != "#" ];then

#del blank START

		if [ -n "$l" ];then

		local dbtype=`echo $l | awk -F \| '{print $1}'`
	
		local dbuser=`echo $l | awk -F \| '{print $2}'`
		
		local dbpwd=`echo $l | awk -F \| '{print $3}'`
		
		local dbhost=`echo $l | awk -F \| '{print $4}'`
		
		local dbport=`echo $l | awk -F \| '{print $5}'`
	
		local dbname=`echo $l | awk -F \| '{print $6}'`
		
		local bakpath=`echo $l | awk -F \| '{print $7}'`
		
		local week=`echo $l | awk -F \| '{print $8}'`
		
		local expire=`echo $l | awk -F \| '{print $9}'`
		
		local charset=`echo $l | awk -F \| '{print $10}'`

#未定义备份日期则使用默认策略每天都备份

[ -z "$week" ] && local week=$def_week

#未定义过期日期则使用配置文件默认时间

[ -z "$expire" ] && local expire=$def_expire

#未定义备份路径则使用配置文件默认路径

[ -z "$bakpath" ] && local bakpath=$def_path

#未定义mysqldump默认编码则使用默认配置

[ -z "$charset" ] && local charset=$def_charset


#根据星期判定备份	

			if [[ $week == *`date +%w`* ]];then

				f_"$dbtype" "$dbhost" "$dbport" "$dbuser" "$dbpwd" "$dbname" "$bakpath" "$expire" "$charset"
			
			fi				

		check_expire "$dbtype" "$dbhost" "$bakpath" "${dbname//,/ }" "$expire"

#del "#" END

		fi

#del blank END

	fi

#while END

done < $f

}

#计时 START

stime=`date +%s`

#启动程序

db_pase $db

#计时 END

etime=`date +%s`

timer "$stime" "$etime"

#若失败为空

if [ -z "$fcount" ];then

#成功不为空

	if [ -n "$scount" ];then

		if [ "$mail_type" == "1" ];then

			send_mail "$mail_file" "iBackup - Suceess { success : $scount }" "RUN $result\n\n$scontent\n\n$fcontent"

		fi
	fi

else

	[ -z "$scount" ] && scount=0
	
	send_mail "$mail_file" "iBackup - Fail { success : $scount , fail : $fcount }" "RUN $result\n\n$fcontent\n\n$scontent"

fi

#结束标记

log "end"
