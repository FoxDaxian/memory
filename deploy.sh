if [ -n `which hexo`]; then
    echo 'hexo exist'
else
    echo 'hexo not exist'
    npm i hexo-cli -g
fi
