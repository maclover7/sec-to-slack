# sec-to-slack

The easiest way to pipe security-vulnerability-mailing-list-emails into
your Slack organization.

### Deployment

Set the following environment variables:

- `SLACK_ANN_CHANNEL` --> This is the Slack channel where the bot will
  be posting to.
- `SLACK_API_TOKEN` --> This is the Slack API token which will be used
  to post the updates. You can generate one of these by creating a "bot"
for you organization.
- `SEC_LISTS` --> This should be an array of security vulnerability
  mailing lists. By default, the bot will listen for emails on the Ruby
on Rails security mailing list.

In order for the service to work, you will also need to set Mailgun up
on your domain. To do so, you will need to do the following:

- Register for an account on mailgun.org.
- Add the MX inbound records for your domain (I recommend using a subdomain).
- Add a "route" which will tell Mailgun that it needs to send inbound
  email hooks to this application:

```
curl -s --user 'api:YOUR_API_KEY' \
    https://api.mailgun.net/v3/routes \
    -F priority=0 \
    -F description='Sec emails' \
    -F expression='catch_all()' \
    -F action='forward("YOUR_APP_DOMAIN_HERE")' \
    -F action='stop()'
```


### License

This code is licensed under the MIT License.

Copyright (c) 2016 Jon Moss
