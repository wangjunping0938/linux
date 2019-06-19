ubuntu-18.04安装更新pip3.md
===


### 安装更新pip3
安装pip3
```Bash
sudo apt-get install python3-pip -y
```

更新pip3
```Bash
sudo pip3 install --upgrade pip
```

修改`/usr/bin/pip3`
```Bash
from pip import __main__
if __name__ == '__main__':
    sys.exit(__main__._main())
```
