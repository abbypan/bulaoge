# bulaoge

download post from bulaoge.net  ,  convert to  mobi ebook

下载bulaoge.net的帖子，自动转换成mobi电子书


## 安装

安装 perl，mobi转换需要安装calibre

cpan App::cpanminus

cpanm Encode::Locale

cpanm Web::Scraper

cpanm Novel::Robot

## 例子

perl bulaoge.pl 'black.f' '二十八岁未成年(2015)' 'http://bulaoge.net/user.blg?dmn=73&cid=261914' 3
