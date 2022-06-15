# How to: perform load testing on Apply

[Apache JMeter](https://jmeter.apache.org/) allows us to test our service with realistic loads.

[ruby-jmeter](https://github.com/flood-io/ruby-jmeter) is a Ruby gem/DSL which wraps JMeter and allows us to [write JMeter plans in Ruby code](/jmeter/plans/apply.rb).

## Instructions

You'll need docker installed.


Once installed you can build the apply-jmeter container:
```
cd jmeter && docker build . -t jmeter
```

And run the `test` plan:

```
docker run --rm -ti --net=host -e JMETER_TARGET_BASEURL=http://localhost:3000 -e JMETER_TARGET_PLAN=test -e JMETER_WAIT_FACTOR=0.5 jmeter
```

### Running real-world plans

You will need some seed data on you local development environment to run the apply/manage/vendor load test plans.

First ensure you local env.development file points `TEACHER_TRAINING_API_BASE_URL` to the QA application. ie. it should have the line:

```
TEACHER_TRAINING_API_BASE_URL=https://qa.api.publish-teacher-training-courses.service.gov.uk/api/public/v1
```

Then run the rake task to seed data into your local development environment (it may be best to start with a clean db for this).

This will take 15 or more minutes to run as it syncs 50 provider and their course data.

```
bundle exec rake load_test:setup_app_data
```

You can now run one of the load test plans against your local machine.

The apply/manage/vendor plans can be specified via the `JMETER_TARGET_PLAN=<plan>` argument like this:

```
docker run --rm -ti --net=host -e JMETER_TARGET_BASEURL=http://localhost:3000 -e JMETER_TARGET_PLAN=manage -e JMETER_WAIT_FACTOR=0.5 -e JMETER_THREAD_CONFIG=0,0,0,0,0,1 jmeter
```

### Debugging

If you'd like to debug a single threaded instance of the test plan run you can specify `-e JMETER_THREAD_COUNT=1` to minimise the requests made to your local server.

## More info

See [further documentation](/jmeter/README.md) on configuring, deploying and monitoring our load test environment.
