# Load testing

[Apache JMeter](https://jmeter.apache.org/) allows us to test our service with realistic loads. 

## Instructions
### 1. Install Apache JMeter
```sh
brew install jmeter
```

### 2. Grab an auth token
- Check the app is running in mid-cycle mode.
- Sign into you application as a user with an application that has been started but not completed.
- Open up your browser dev console and grab the value of `_apply_for_postgraduate_teacher_training_session` from the cookies.

### 3. Generate a test plan
- Generate the test plan with the following command passing in the token you grabbed earlier. You can optionally set the host and thread count if you want to else it will revert to defaults.
```sh
bundle exec rake generate_jmeter_plan[HOST,THREAD_COUNT,TOKEN]
```

Note: you can also run your plan as part of the rake task in order to iron out bugs. Replace the call to `.jmx` with `.run` 

### 4. Run your plan on your JMeter instance
From here you can either choose to run your plan from the command line or the GUI if you want to configure bar charts and tables.

