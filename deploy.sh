ls -l
cd ./blog
ls -l
hexo clean
hexo generate
git config user.name 'Foxdaxian'
git config user.email '945039036@qq.com'
hexo deploy
echo '结束'