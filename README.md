I downloaded the [Turnkey Linux - LAMP stack](http://www.turnkeylinux.org/lampstack) (for VMWare) and added it to VMWare player. Prior to starting it up I switched its networking to NAT, since my home router doesn't treat bridged hosts well.


Upon starting it, I added its IP to the host computer's /etc/hosts file with the hostname **habari-test**:

```192.168.12.130     habari-test```


After starting up the VM, I logged in and installed all the packages needed:

```bash
apt-get install ruby rubygems ruby-full build-essential libxml2-dev libmysqlclient16-dev libxslt-dev firefox xvfb openjdk-6-jre
```


Git, Apache, MySQL and PHP were already installed, so if you're putting this together elsewhere you'd need to grab those as well (apt-get install git lamp-server^)


There are several ruby gems needed. This part seems to take the longest.

```bash
gem install gherkin rspec mechanize capybara-mechanize mysql cucumber 
```

By default these are not added to the path. Add it to the end of the **~/.bashrc** PATH line (or put it in /etc/environment for all users of Ubuntu):

```bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/lib/gems/1.8/bin
```


At this point **Xvfb** can be started to provide a headless display to run Firefox for tests needing javascript. I typically start up **gnu screen** and run these in display 0:

```bash
root@lamp ~# Xvfb -ac :99 &
```

Start up mysql (using the root password you set at installation) and create a test user with necessary permissions:

```bash
root@lamp ~# mysql -u root -p
```
```sql
mysql> create database test; grant usage on *.* to test@localhost identified by 'test'; grant all privileges on test.* to test@localhost;
```

That database is going to be dropped and recreated many a time, so don't get too attached to it. The important parts are the permissions, anyway. At some point I'll probably want to not use the same database name, username, and password for clarity.

At this point the vhost needs to be set up. Create a new Apache conf file.

```bash
root@lamp ~# nano /etc/apache2/sites-available/habari-test
```

```
<VirtualHost *:80>
ServerName habari-test
ServerAdmin yourname@yourdomain.com
DocumentRoot /var/www/habari/
</VirtualHost>
```

Symlink the new configuration. Now's as good a time as any to enable **mod_rewrite**, so do that also before restarting Apache.

```bash
root@lamp ~# ln -s /etc/apache2/sites-available/habari-test /etc/apache2/sites-enabled/habari-test
root@lamp ~# a2enmod rewrite
root@lamp ~# /etc/init.d/apache2 restart
```

Add the **habari-test** hostname to the VM's hosts file (/etc/hosts):

```127.0.0.1     habari-test```

There are not files currently in **/var/www/habari**. You'll use Git to get them there, but first it needs to be configured. Set up your Git credentials (if you haven't already) and copy the public key to [your github account](https://github.com/account/ssh).

```bash
root@lamp ~# git config --global user.name "Firstname Lastname"
root@lamp ~# git config --global user.email "yourname@youremail.com"
root@lamp ~# ssh-keygen -t rsa -C "yourname@youremail.com"
root@lamp ~# cat ~/.ssh/id_rsa.pub
```

Clone the Habari repository. Note this guide is written assuming you have write privileges to that repository.

```bash
root@lamp ~# cd /var/www
root@lamp var/www# git clone git@github.com:habari/habari.git
```

Add this repository as a submodule, and initialize the submodules. Then switch habari/system to use the master branch.

```bash
root@lamp var/www# cd habari 
root@lamp www/habari# git submodule add git@github.com:mikelietz/cucumber-for-habari.git tests
root@lamp www/habari# git submodule update --init
root@lamp www/habari# cd system
root@lamp habari/system# git checkout master 
```

Change the ownership so Habari can install:

```bash
root@lamp ~# chown -R www-data:www-data /var/www/habari
```

You should now be able to run **cucumber** (in the Xvfb display) and test the installer.

```bash
root@lamp ~# cd /var/www/habari/tests/
root@lamp habari/tests# DISPLAY=:99 cucumber features/installer.feature
```
