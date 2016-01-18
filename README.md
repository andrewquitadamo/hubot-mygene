# hubot-mygene
A hubot script to interact with the [mygene.info](http://mygene.info) API. 

See [src/mygene.coffee](https://github.com/andrewquitadamo/hubot-mygene/blob/master/src/mygene.coffee) for full documentation.

##Installation
In hubot project repo, run:

`npm install hubot-mygene --save`

Then add **hubot-mygene** to your `external-scripts.json`:

```json
[
  "hubot-mygene"
]
```

## Sample Interaction
```
user>> hubot get gene symbol 672
hubot>> BRCA1
user>> hubot get omim 672
hubot>> 113705    http://www.omim.org/entry/113705
user>> hubot get map location 672
hubot>> 17q21
```
