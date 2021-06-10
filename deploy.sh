# 如果是发布到自定义域名
echo 'cs-review.cn' > CNAME

git init
git config user.name "WosAlan"
git config user.email "806452789@qq.com"
git add -A
git commit -m '更新了样式'

# 如果你想要部署到 coding上
# .ssh -> config -> nodeing666 对应e.coding.net
# git@e.coding.net:wosalan/vuepressblog/blog.git
git push -f git@alan666:Alan-26/CS_Review.git master
# 如果发布到 https://USERNAME.github.io/<REPO>  REPO=github上的项目
# git push -f git@github.com:USERNAME/<REPO>.git master:gh-pages
cd -