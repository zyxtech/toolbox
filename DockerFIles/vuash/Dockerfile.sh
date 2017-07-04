FROM ubuntu:17.04
MAINTAINER zyxtech@hotmail.com
RUN apt-get update
RUN apt-get install -y ruby-full
RUN apt-get install -y git
RUN git clone https://github.com/current/vuash
RUN groupadd vuash
RUN useradd -p "vuash" -d /home/vuash -m -g vuash -s /bin/bash "vuash"
RUN chown vuash:vuash -R vuash
WORKDIR /vuash
RUN sed -i "s/^ruby/#ruby/" Gemfile
RUN gem install bundler
RUN apt-get install -y build-essential
RUN apt-get -y install libpq-dev
RUN apt-get install -y zlib1g-dev
RUN gem install nokogiri -v '1.6.6.2'
RUN bundle update rdoc
RUN gem install pg -v '0.18.2'
#install postgresql
RUN apt-get install -y postgresql postgresql-contrib
ADD initserver.sh /initserver.sh
RUN /bin/bash /initserver.sh
EXPOSE 3000
ADD startup.sh /startup.sh
ENTRYPOINT ["/bin/bash","/startup.sh"]