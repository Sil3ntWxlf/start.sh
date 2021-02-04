#| A minecraft server start script
**_Must have lolcat & toilet installed on box_**
####

###What is lolcat?
> Lolcat is a utility for Linux, BSD and OSX which concatenates like similar to cat command and adds rainbow coloring to it. Lolcat is primarily used for rainbow coloring of text in Linux Terminal.

###Installation of Lolcat in Linux
> Lolcat utility is available in the repository of lots of Linux distributions, but the available version bit older. Alternatively you can download and install the latest version of lolcat from git repository.

###Lolcat is a ruby gem hence it is essential to have the latest version of RUBY installed on your system.

Commands                   |     Info
---------------------------|--------------------------
apt-get install ruby	|	[On APT based Systems]
yum install ruby	|	[On Yum based Systems]
dnf install ruby	|	[On DNF based Systems]

###Once ruby package has been installed, make sure to verify the version of ruby installed.
>#### ruby --version

##ruby 2.1.5p273 (2014-11-13) [x86_64-linux-gnu]
#### Next download and install the most recent version of lolcat from the git repository using following commands:

Commands                      |         |
---------------------------|------------------------------
wget https://github.com/busyloop/lolcat/archive/master.zip | |
unzip master.zip              |         |
cd lolcat-master/bin          |         |
gem install lolcat            |         |

###Once lolcat is installed, you can check the version.

>#### lolcat --version
>#### lolcat 42.0.99 (c)2011 moe@busyloop.net
###Usage of Lolcat
> Before starting usage of lolcat, make sure to know the available options and help using the following command:
> 
>#### lolcat -h

### Lolcat Help
> Next, pipeline lolcat with commands say ps, date and cal as:
> 
>> ps | lolcat
> 
>> date | lolcat
> 
>> cal | lolcat

>## Use lolcat to display codes of a script file as:
> 
>**lolcat test.sh**
> 
>**Display Codes with Lolcat**
> 
>**Display Codes with Lolcat**

> Pipeline lolcat with figlet command. Figlet is a utility which displays large characters made up of ordinary screen characters. We can pipeline the output of figlet with lolcat to make the output colorful as:
> 
>> echo I ❤ Tecmint | lolcat
> 
>> figlet I Love Tecmint | lolcat
>
> Note: Not to mention that ❤ is an unicode character and to install figlet you have to yum and apt to get the required packages as:

> apt-get figlet
> yum install figlet
> dnf install figlet
    7. Animate a text in rainbow of colours, as:

> $ echo I ❤ Tecmint | lolcat -a -d 500
> 
> Here the option -a is for Animation and -d is for duration. In the above example duration count is 500.
    8. Read a man page (say man ls) in rainbow of colors as:

> man ls | lolcat
    9. Pipeline lolcat with cowsay. cowsay is a configurable thinking and/or speaking cow, which supports a lot of other animals as well.
