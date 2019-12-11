# Deploying Joseki APIs on Google Cloud Platform's Cloud Run

This example roughly follows the instructions 
[here](https://cloud.google.com/run/docs/quickstarts/build-and-deploy).  You may need to go through
the "Before you begin" steps there.

## Building the container

Assuming your project is called `joseki` and you want to deploy the project as
`simple_joseki_server` you can use the Google cloud SDK to submit and build the container remotely:  

```shell
gcloud builds submit --tag gcr.io/joseki/simple_joseki_server
```

After it finishes, you can deploy the result with:

```shell
gcloud run deploy --image gcr.io/joseki/simple_joseki_server --platform managed --memory 512Mi
```

Make sure to answer `Y` to the "Allow unauthenticated invocations to...".  It should report a URL
that you can go to and see that the API is working.  

## Disclaimer

The primary author of this package is a Google employee, but this is not an official Google product or endorsed by Google in any way.  