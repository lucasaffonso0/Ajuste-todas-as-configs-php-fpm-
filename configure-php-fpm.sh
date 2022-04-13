#!/bin/bash

while [[ $process_manage != 1 ]] && [[ $process_manage != 2 ]]; do
    echo -en "[1] Dynamic\n[2] On Demand\n\nEscolha uma opção:"
    read process_manage

    if [[ $process_manage = 1 ]] ; then
        process_manage='dynamic'
        echo -en "pm.start_servers:"
        read sub_start_servers
        echo -en "pm.min_spare_servers:"
        read sub_min_spare_servers
        echo -en "pm.max_spare_servers:"
        read sub_max_spare_servers
        echo -en "request_terminate_timeout:"
        read sub_request_terminate_timeout
        for config in `ls /etc/php/$1/fpm/pool.d`; do
            if [ "www.conf" != $config ] ; then
                start_servers=`grep "start_servers" /etc/php/$1/fpm/pool.d/$config | cut -d '=' -f2 | cut -d 's' -f1 | xargs`
                min_spare_servers=`grep "min_spare_servers" /etc/php/$1/fpm/pool.d/$config | cut -d '=' -f2 | cut -d 's' -f1 | xargs`
                max_spare_servers=`grep "max_spare_servers" /etc/php/$1/fpm/pool.d/$config | cut -d '=' -f2 | cut -d 's' -f1 | xargs`
                request_terminate_timeout=`grep "request_terminate_timeout" /etc/php/$1/fpm/pool.d/$config | cut -d '=' -f2 | cut -d 's' -f1 | xargs`
                sudo sed -i "s/\(;\)*pm.start_servers = $start_servers/pm.start_servers = $sub_start_servers/g" /etc/php/$1/fpm/pool.d/$config
                sudo sed -i "s/\(;\)*pm.min_spare_servers = $min_spare_servers/pm.min_spare_servers = $sub_min_spare_servers/g" /etc/php/$1/fpm/pool.d/$config
                sudo sed -i "s/\(;\)*pm.max_spare_servers = $max_spare_servers/pm.max_spare_servers = $sub_max_spare_servers/g" /etc/php/$1/fpm/pool.d/$config
                sudo sed -i "s/\(;\)*request_terminate_timeout = $request_terminate_timeout/request_terminate_timeout = $sub_request_terminate_timeout/g" /etc/php/$1/fpm/pool.d/$config
                sudo sed -i "s/\(;\)*pm.process_idle_timeout/;pm.process_idle_timeout/g" /etc/php/$1/fpm/pool.d/$config
                sudo sed -i "s/\(;\)*pm.start_servers/pm.start_servers/g" /etc/php/$1/fpm/pool.d/$config
                sudo sed -i "s/\(;\)*pm.min_spare_servers/pm.min_spare_servers/g" /etc/php/$1/fpm/pool.d/$config
                sudo sed -i "s/\(;\)*pm.max_spare_servers/pm.max_spare_servers/g" /etc/php/$1/fpm/pool.d/$config
            fi
        done
        break
    elif [[ $process_manage = 2 ]] ; then
        process_manage='ondemand'
        echo -en "pm.process_idle_timeout:"
        read sub_process_idle_timeout
        for config in `ls /etc/php/$1/fpm/pool.d`; do
            if [ "www.conf" != $config ] ; then
                process_idle_timeout=`grep "process_idle_timeout" /etc/php/$1/fpm/pool.d/$config | cut -d '=' -f2 | cut -d 's' -f1 | xargs`
                sudo sed -i "s/\(;\)*pm.process_idle_timeout = $process_idle_timeout/pm.process_idle_timeout = $sub_process_idle_timeout/g" /etc/php/$1/fpm/pool.d/$config
                sudo sed -i "s/\(;\)*pm.start_servers/;pm.start_servers/g" /etc/php/$1/fpm/pool.d/$config
                sudo sed -i "s/\(;\)*pm.min_spare_servers/;pm.min_spare_servers/g" /etc/php/$1/fpm/pool.d/$config
                sudo sed -i "s/\(;\)*pm.max_spare_servers/;pm.max_spare_servers/g" /etc/php/$1/fpm/pool.d/$config
                sudo sed -i "s/\(;\)*request_terminate_timeout/;request_terminate_timeout/g" /etc/php/$1/fpm/pool.d/$config
            fi
        done
        break
    else
        echo -e "\e[31mOpção Incorreta!\e[0m"
    fi
done
echo -en "pm.max_children:"
read sub_max_children
echo -en "pm.max_requests:"
read sub_max_requests
for config in `ls /etc/php/$1/fpm/pool.d`; do
    if [ "www.conf" != $config ] ; then
        max_children=`grep "max_children" /etc/php/$1/fpm/pool.d/$config | cut -d '=' -f2 | cut -d 's' -f1 | xargs` 
        sudo sed -i "s/pm.max_children = $max_children/pm.max_children = $sub_max_children/g" /etc/php/$1/fpm/pool.d/$config
        max_requests=`grep "max_requests" /etc/php/$1/fpm/pool.d/$config | cut -d '=' -f2 | cut -d 's' -f1 | xargs`
        sudo sed -i "s/pm.max_requests = $max_requests/pm.max_requests = $sub_max_requests/g" /etc/php/$1/fpm/pool.d/$config
        sub_process_manage=`grep "pm =" /etc/php/$1/fpm/pool.d/$config | cut -d '=' -f2 | xargs`
        sudo sed -i "s/pm = $sub_process_manage/pm = $process_manage/g" /etc/php/$1/fpm/pool.d/$config
    fi
done
