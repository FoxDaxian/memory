cd ./blog
if which hexo>/dev/null; then
  echo "hexo存在!"
else
  echo "hexo不存在，马上安装"
  npm install -g hexo
fi