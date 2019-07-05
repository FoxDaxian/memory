if which hexo 2>/dev/null; then
  echo "hexo exists!"
else
  echo "nope, no hexo installed."
fi

cd ./blog
hexo generate
mv ./public blog
ll ./blog