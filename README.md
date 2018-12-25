## c- (CMinus)
### A lightweight changing directory command (cd) bash script

#### Usage:
c- is quite simple and intuitive, aiming minmal code to ehance your path-changing efficency.

You can watch the movie to see how it is like.
![Movie](https://youtu.be/b8Bem53Cz9A)

git clone https://github.com/whitebob/cminus

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
now hit the `tab`, you will see "/var/log" shown in your line.

"-f" means fuzzy, and if you want to use `c- --fuzzy` it is also OK.

Now things become insteresting, you can go a specific visited dir even you only remember part of its path.


Want more? the fuzzy match support regular expression...Hmm... Try this!
```bash
c- -f r$
```
now hit the `tab`, "/var" is the only match for your choice.

Of cause you could use the .* or ? in the fuzzy search just as what you would do using grep,
because that's exactly the command the script running behind. :p 

Oh, I have to mention cminus could deal with spaces in path, which makes one simple idea take more lines to
complete, but it worths...

Try more and I wish you feel better because it is just so natural as things should have be.     

You may save the visited file paths by
```bash
c- -s ./workspace.txt
```
and load them later by 
```bash
c- -l ./workspace.txt
```
The format is plain pathes, one path per line. 
Just the same as `find` output, please help yourself to generate and load if you want,
or you can try this for free :p (DON'T TRY THIS UNDER A HEAVY DIR!!!)  
```bash
c- -l <(find `pwd` -type d)
``` 

It is quite likely after the loading, you have some duplicated entries in your DIRSTACK. you may check them by 
```bash
dirs -l
```
Here `dirs` is a built-in command in bash (by the way, `dirs -c` will clean the tracks). Don't worry, you can refresh 
```bash
c- -r
```
to make the stack items unique and sorted, saving some memory (Maybe...) :p

OK, that's almost all of the cminus. If you feel anything not comfortable or anything needs to improve, 
let's go together to see how to make it. Wellcome to hack the code and diss me if you have better solutions.    

Afterall, life should be easy, isn't it?

#### Why do we need CMinus since we have autojump, z, fasd and so on ?

if you look into the code of CMinus, you will know why I want this:

1. pure bash and almost no install depenency . (binutils and tools such as md5 and sed are installed by default in most cases), no contamination.  
2. less than 50 lines of codes 
3. smart auto pushd compatible with space seperated dirname such as m\ n
4. fuzzy searching without using fzf, ctrlp or anything need to install 
5. cminus is not going to be the replacement of cd, autojump, j, z or fasd, because its function is quite limited, only to help you change to dirs you
   have travelled or loaded from saved paths.
