## Deploying

After updating the content make sure to run

```
JEKYLL_ENV=production bundle exec jekyll build
```

Building in production mode means that google anlytics will be enabled etc.
Now run

```
docker build -t hqmq/blog:[[DATE]]
docker push hqmq/blog:[[DATE]]
```

And finally login to rancher and upgrade the blog service to use the new tag that you just built and pushed.

## Developing

When working on new content you can run `bundle exec jekyll server` and browser to `http://localhost:4000/` to check out your changes.
