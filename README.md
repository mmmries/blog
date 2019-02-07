## Deploying

After updating the content make sure to run

```
JEKYLL_ENV=production bundle exec jekyll build
```

Building in production mode means that google anlytics will be enabled etc.
Now run

```
date=2018-07-28
docker build -t hqmq/blog:$date .
docker tag hqmq/blog:$date hqmq/blog:latest
docker push hqmq/blog:$date
docker push hqmq/blog:latest
```

And finally login to rancher and upgrade the blog service to use the new tag that you just built and pushed.

## Developing

When working on new content you can run `bundle exec jekyll server` and browser to `http://localhost:4000/` to check out your changes.
