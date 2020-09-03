FROM debian:buster-slim

LABEL Description="Intuitive local web frontend for the BLAST bioinformatics tool"
LABEL MailingList="https://groups.google.com/forum/#!forum/sequenceserver"
LABEL Website="http://www.sequenceserver.com"

RUN apt-get update && apt-get install -y --no-install-recommends \
        ruby ruby-dev build-essential curl gnupg git wget \
        zlib1g-dev && rm -rf /var/lib/apt/lists/*

VOLUME ["/db"]
EXPOSE 4567

RUN wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.9.0/ncbi-blast-2.9.0+-x64-linux.tar.gz 
RUN tar zxf ncbi-blast-2.9.0+-x64-linux.tar.gz
RUN mv ncbi-blast-2.9.0+/bin/* /usr/bin/ 
RUN mkdir -p ~/.sequenceserver

COPY . /sequenceserver
WORKDIR /sequenceserver
# Install bundler, then use bundler to install SequenceServer's dependencies,
# and then use SequenceServer to install BLAST. In the last step, -s is used
# so that SequenceServer will exit after writing configuration file instead
# of starting up, while -d is used to suppress questions about database dir.
RUN gem install bundler && \
        bundle install --without=development && \
        yes '' | bundle exec bin/sequenceserver -s -d spec/database/sample
RUN touch ~/.sequenceserver/asked_to_join

# 40 = CPU threads
CMD ["bundle", "exec", "bin/sequenceserver", "-d", "/db", "-n", "40"]
