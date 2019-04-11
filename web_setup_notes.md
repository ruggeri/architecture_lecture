**Step 1: Start An EC2 Instance**

Start an Ubuntu instance. Show how to SSH into it.

Open ports 80, 3000, 3001, 5432.

Setup subdomain like `test.self-loop.com` to point to the instance.

**Step 2: Install Ruby**

* `sudo apt-get update`
* `sudo apt-get install ruby`
* `sudo apt-get install build-essential patch ruby-dev zlib1g-dev liblzma-dev`
    * Required to build native extensions for Ruby.
    * In particular, for Nokogiri.
* `sudo apt-get install libsqlite3-dev`
* Install Node (needed for Rails):
    * `curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -`
    * `sudo apt-get install node`
* `sudo gem install rails`
* `sudo rails s -b ec2_domain_name -p 80`

**Step 3: Use Nginx to Proxy**

* `sudo apt-get install nginx`
    * Use `sudo systemctl restart nginx` (it will tell you how to read
      its logs if parsing fails).
    * Can add `error_log /home/ubuntu/nginx.log warn;` if you want to
      get more warnings.

Update Nginx configuration at `/etc/nginx/sites-enabled/default`:

```
upstream backend {
    server localhost:3000;
    server localhost:3001;
}

server {
    location / {
        proxy_pass http://backend;
        # Make sure any of that try_files crap is cleared out.
    }
}
```

**Step 4: Connect To Postgres Remotely**

* `sudo apt-get install postgresql libpq-dev`
* `sudo su postgres` and then in psql:
    * `CREATE USER ubuntu WITH SUPERUSER LOGIN PASSWORD 'my_secret_password';`
* Now you can `rails new my_test_application --database=postgresql`.
    * set `host: localhost` and `username: ubuntu`. I think it will
      work fine because postgres doesn't require a password if your
      current username is the same as the postgres user.
    * But as soon as you do things *remotely* (connect to a box over
      TCP sockets), you'll need to do some things.
* Edit `/etc/postgresql/10/main/postgresql.conf` to add
  `listen_addresses='*'`. This tells postgresql to listen beyond
  localhost.
* Next, update `/etc/postgresql/10/main/pg_hba.conf` to allow md5
  (that is, password) authentication.
    * For `host`, you want `all` databases, `all` users, `0.0.0.0/0`
      for *all* IP addresses. And of course the method is `md5`.
* Of course, `sudo systemctl restart postgresql`.
