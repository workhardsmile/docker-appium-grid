FROM hub.c.163.com/workhardsmile/citest:slave-base

#COPY ./ssh /root/.ssh
RUN chmod -R 600 /root/.ssh \
    && mkdir -p /test-slave \
    && rm -f /Gemfile*
VOLUME ["/test-slave"]
CMD ["ruby", "/test-slave/testplus_run.rb"]