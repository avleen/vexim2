
## CLI for Vexim2

These files assume you have passwordless Mysql access to localhost i.e. proper settings in /root/.my.cnf 

They also assume DB name is set :

```
echo DB=vexim2 >> /etc/vexim2.conf
```


### Installation

```
cp -v bin/vexim2_* /usr/local/bin/
chmod +x /usr/local/bin/vexim2_*
```

### Usage

All commands are safe to run without arguements. If they need some, they will ask for.

