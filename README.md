## CF Continuous Test

This pipeline runs smoke tests on your Cloud Foundry platform periodically.

### Creating a user

Login with the CF cli and then create a user/space combination and give it access:

```
cf create-user system-tester PASSWORD

cf create-space smoke-tests -o system
cf set-space-role system-tester system smoke-tests SpaceManager
cf set-space-role system-tester system smoke-tests SpaceDeveloper
```

### Set params.yml variables

Make a copy of `params.yml` and fill in the variables.

### Fly pipeline

`fly -t concourse set-pipeline -p smoke-tests -c pipeline.yml -l params.yml`
