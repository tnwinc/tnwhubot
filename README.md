# Archive Note
This repo is obsolete and no longer being used. Archiving it to keep its historical value.

# Hubot

This is a version of GitHub's Campfire bot, hubot. He's pretty cool.

This version is designed to be deployed on [Heroku][heroku].

[heroku]: http://www.heroku.com

## Playing with Hubot

You'll need to install the necessary dependencies for hubot. All of
those dependencies are provided by [npm][npmjs].

[npmjs]: http://npmjs.org

## HTTP Listener

Hubot has a HTTP listener which listens on the port specified by the `PORT`
environment variable.

You can specify routes to listen on in your scripts by using the `router`
property on `robot`.

```coffeescript
module.exports = (robot) ->
  robot.router.get "/hubot/version", (req, res) ->
    res.end robot.version
```

There are functions for GET, POST, PUT and DELETE, which all take a route and
callback function that accepts a request and a response.

### Redis

If you are going to use the `redis-brain.coffee` script from `hubot-scripts`
you will need to add the Redis to Go addon on Heroku which requires a verified
account or you can create an account at [Redis to Go][redistogo] and manually
set the `REDISTOGO_URL` variable.

    % heroku config:add REDISTOGO_URL="..."

If you don't require any persistence feel free to remove the
`redis-brain.coffee` from `hubot-scripts.json` and you don't need to worry
about redis at all.

[redistogo]: https://redistogo.com/

### Testing Hubot Locally

You can test your hubot by running the following.

    % bin/hubot

You'll see some start up output about where your scripts come from and a
prompt.

    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading adapter shell
    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading scripts from /home/tomb/Development/hubot/scripts
    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading scripts from /home/tomb/Development/hubot/src/scripts
    Hubot>

Then you can interact with hubot by typing `hubot help`.

    Hubot> hubot help

    Hubot> animate me <query> - The same thing as `image me`, except adds a few
    convert me <expression> to <units> - Convert expression to given units.
    help - Displays all of the help commands that Hubot knows about.
    ...

Take a look at the scripts in the `./scripts` folder for examples.
Delete any scripts you think are silly.  Add whatever functionality you
want hubot to have.

## Adapters

Adapters are the interface to the service you want your hubot to run on. This
can be something like Campfire or IRC. There are a number of third party
adapters that the community have contributed. Check the
[hubot wiki][hubot-wiki] for the available ones.

If you would like to run a non-Campfire or shell adapter you will need to add
the adapter package as a dependency to the `package.json` file in the
`dependencies` section.

Once you've added the dependency and run `npm install` to install it you can
then run hubot with the adapter.

    % bin/hubot -a <adapter>

Where `<adapter>` is the name of your adapter without the `hubot-` prefix.

[hubot-wiki]: https://github.com/github/hubot/wiki

## hubot-scripts

There will inevitably be functionality that everyone will want. Instead
of adding it to hubot itself, you can submit pull requests to
[hubot-scripts][hubot-scripts].

To enable scripts from the hubot-scripts package, add the script name with
extension as a double quoted string to the hubot-scripts.json file in this
repo.

[hubot-scripts]: https://github.com/github/hubot-scripts

## Deployment

    % heroku create --stack cedar
    % git push heroku master
    % heroku ps:scale app=1

If your Heroku account has been verified you can run the following to enable
and add the Redis to Go addon to your app.

    % heroku addons:add redistogo:nano

If you run into any problems, checkout Heroku's [docs][heroku-node-docs].

You'll need to edit the `Procfile` to set the name of your hubot.

More detailed documentation can be found on the
[deploying hubot onto Heroku][deploy-heroku] wiki page.

### Deploying to UNIX or Windows

If you would like to deploy to either a UNIX operating system or Windows.
Please check out the [deploying hubot onto UNIX][deploy-unix] and
[deploying hubot onto Windows][deploy-windows] wiki pages.

[heroku-node-docs]: http://devcenter.heroku/com/articles/node-js
[deploy-heroku]: https://github.com/github/hubot/wiki/Deploying-Hubot-onto-Heroku
[deploy-unix]: https://github.com/github/hubot/wiki/Deploying-Hubot-onto-UNIX
[deploy-windows]: https://github.com/github/hubot/wiki/Deploying-Hubot-onto-Windows

## Campfire Variables

If you are using the Campfire adapter you will need to set some environment
variables. Refer to the documentation for other adapters and the configuraiton
of those, links to the adapters can be found on the [hubot wiki][hubot-wiki].

Create a separate Campfire user for your bot and get their token from the web
UI.

    % heroku config:add HUBOT_CAMPFIRE_TOKEN="..."

Get the numeric IDs of the rooms you want the bot to join, comma delimited. If
you want the bot to connect to `https://mysubdomain.campfirenow.com/room/42` 
and `https://mysubdomain.campfirenow.com/room/1024` then you'd add it like this:

    % heroku config:add HUBOT_CAMPFIRE_ROOMS="42,1024"

Add the subdomain hubot should connect to. If you web URL looks like
`http://mysubdomain.campfirenow.com` then you'd add it like this:

    % heroku config:add HUBOT_CAMPFIRE_ACCOUNT="mysubdomain"

[hubot-wiki]: https://github.com/github/hubot/wiki

## Restart the bot

You may want to get comfortable with `heroku logs` and `heroku restart`
if you're having issues.

