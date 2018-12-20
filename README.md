## c- (CMinus)
### A lightweight changing directory command (cd) bash script

#### Usage:
c- is quite simple and intuitive, aiming minmal code to ehance your path-changing efficency.

git clone ...

put cminus.sh into where your bash could auto source it. 

For example:

copy the cminus.sh to your home 

put this line into your ~/.bashrc:

source ./cminus.sh

now enjoy!

Go around as you like several times, like this 

```bash
$ cd /
$ cd /var/log
$ cd /bin
$ cd /sbin/
```
After some of operations, now input  `c- ` and hit `<tab>` key:
you will see this:

```bash
$c- /
```
and hit `<tab>` twice:
```bash
$c- /
/                     /bin                     /sbin                    /usr/bin                 /usr/sbin                /var                     /var/log
```
You will see all the tracks traveled previously. 

Suppose you want to go back to "/sbin", now hit `s<tab>` to see the full path jump to your line.

```bash
$c- /sbin
```
And if you want to go "/usr/sbin", now delete the `sbin` and  hit `u`, press `<tab>` again :
```bash
$c- /usr/
```
Now you have two candidates "/usr/sbin" and "/usr/bin", hit`<tab>` twice again, you will see them both:

```bash
$c- /usr/
/usr/bin   /usr/sbin
```
hit `s` and press `<tab>`, now you get what you want.

Simple and intuitive, isn't it? 

we have something better! input this:

```bash
c- -f lo
```
now hit the `<key>tab</key>`, you will see "/var/log" shown in your line.

"-f" means fuzzy, and if you want to use `c- --fuzzy` it is also OK.

now things become insteresting, you can go a specific visited dir even you only remember part of its path.

life should be easy, isn't it?

#### Why do we need CMinus since we have autojump, z, asdf and so on ?

if you look into the code of CMinus, you will know why I want this:

1.  pure bash  and almost no install depenency . (binutils such as md5 and sed are installed by default in most cases), no contamination.  
2. less than 30 lines of codes 
3. smart auto pushd compatible with space seperated dirname such as m\ n
4. fuzzy searching without using fzf ctrlp or anything need to install 