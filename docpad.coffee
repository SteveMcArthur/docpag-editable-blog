# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
fs = require('fs')
util = require('util')
docpadConfig = {

    #port:5858

    #maxAge: false

    #regenerateDelay: 1000

    # =================================
    # Template Data
    # These are variables that will be accessible via our templates
    # To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

    templateData:

        # Specify some site properties
        site:
            # The production url of our website
            # If not set, will default to the calculated site URL (e.g. http://localhost:9778)
            url: "http://localhost:9778"

            # Here are some old site urls that you would like to redirect from
            oldUrls: [
                'www.docpad.org',
                'website.herokuapp.com'
            ]

            # The default title of our website
            title: "Editable Blog"

            # The website description (for SEO)
            description: """
                When your website appears in search results in say Google, the text here will be shown underneath your website's title.
                """

            # The website keywords (for SEO) separated by commas
            keywords: """
                place, your, website, keywoards, here, keep, them, related, to, the, content, of, your, website
                """

            # The website's styles
            styles: [
                "/css/normalize.css"
                "/css/foundation.css"
                "/css/footer-bottom.css"
                "/css/styles.css"
            ]

            # The website's scripts
            scripts: [
                '/js/jquery.js'
                '/js/foundation/foundation.js'
                """
                <script>$(document).foundation();</script>
                """
            ]


        # -----------------------------
        # Helper Functions

        # Get the prepared site/document title
        # Often we would like to specify particular formatting to our page's title
        # we can apply that formatting here
        getPreparedTitle: ->
            # if we have a document title, then we should use that and suffix the site's title onto it
            if @document.title
                "#{@document.title} | #{@site.title}"
            # if our document does not have it's own title, then we should just use the site's title
            else
                @site.title

        # Get the prepared site/document description
        getPreparedDescription: ->
            # if we have a document description, then we should use that, otherwise use the site's description
            @document.description or @site.description

        # Get the prepared site/document keywords
        getPreparedKeywords: ->
            # Merge the document keywords with the site keywords
            @site.keywords.concat(@document.keywords or []).join(', ')

        # Get a list of all categories from all posts
        getCategories: ->
            cat = []
            # iterate thru documents
            @getCollection('posts').forEach (document) ->
                docat = document.getMeta().get('category')
                if !(docat in cat)
                    cat.push(docat)
            return cat

         # Get a list of all categories from all posts
        getTags: ->
            tags = []
            dc = []
            # iterate thru documents
            @getCollection('posts').forEach (document) ->
                doctags = document.getMeta().get('tags')
                if typeof doctags == 'string'
                    doctags = doctags.split(',')
                dc.push(doctags)
                if doctags
                    for tag in doctags
                        if !(tag in tags)
                            tags.push(tag)
            return tags

         #for debugging purposes
        writeObject: (name,obj) ->
            fs.writeFile(name+".json",util.inspect(obj))

        getSlugFromURL : (url) ->
            items = url.split("\/")
            items[items.length-1].toLowerCase().replace(".html","")

        getSlugFromUrl : @getSlugFromURL

        getDocumentFromSlug : (slug) ->
            document = @getCollection('documents').findOne({slug: slug})

        # Get the current year
        thisYear: (new Date()).getFullYear()

        # Used for shortening a post
        truncateText: (content,trimTo) ->
            trimTo = trimTo || 200
            output = content.substr(0,trimTo).trim()
            #remove anchor tags as they don't show up on the page
            nolinks = output.replace(/<a(\s[^>]*)?>.*?<\/a>/ig,"")
            #check if there is a difference in length - if so add this
            #difference to the trimTo length (add the text length that will not show
            #up in the rendered HTML
            diff = output.length - nolinks.length
            output = content.substr(0,trimTo + diff)
            #find the last space so that don't break the text
            #in the middle of a word
            i = output.lastIndexOf(' ',output.length-1)
            output.substr(0,i)+"..."

        getRecentPosts: ->
            posts = @getCollection('documents').findAllLive({relativeOutDirPath: 'posts'},[{date:-1}])
            return [posts.at(2).toJSON(),posts.at(3).toJSON()]

        getComments: (slug) ->
            @getCollection('comments').findAll({'postslug': slug},[{date:-1}])

        getByCateogory: (category) ->
            @getCollection('posts').findAll({'category':category},[{date:-1}])




    # =================================
    # Collections

    # Here we define our custom collections
    # What we do is we use findAllLive to find a subset of documents from the parent collection
    # creating a live collection out of it
    # A live collection is a collection that constantly stays up to date
    # You can learn more about live collections and querying via
    # http://bevry.me/queryengine/guide

    collections:

        # Create a collection called posts
        # That contains all the documents that will be going to the out path posts
        posts: ->
            @getCollection('documents').findAllLive({relativeOutDirPath: 'posts'},[{date:-1}])
        popularPosts: ->
            @getCollection('documents').findAllLive({relativeOutDirPath: 'posts',popular:$exists:true},[{date:-1}])
        #comments: ->
            #@getCollection('documents').findAllLive({relativeOutDirPath: 'comments'},[{date:-1}])
        pdfs: ->
            @getCollection('files').findAllLive({relativeOutDirPath: 'pdfs'},[{date:-1}])
        tags: ->
            @getCollection('posts').findAllLive({tags:$exists:true})

    # Regenerate Every
    # Performs a regenerate every x milliseconds, useful for always having the latest data
    #regenerateEvery: false  # default = false


    # =================================
    # Environments

    # DocPad's default environment is the production environment
    # The development environment, actually extends from the production environment

    # The following overrides our production url in our development environment with false
    # This allows DocPad's to use it's own calculated site URL instead, due to the falsey value
    # This allows <%- @site.url %> in our template data to work correctly, regardless what environment we are in
    env: 'production'

    environments:
        development:  # default
            # Always refresh from server
            maxAge: false  # default

            # Check for environment variables that the app will listen on the various cloud environments (this case, openshift)
            port: process.env.PORT || process.env.OPENSHIFT_NODEJS_PORT || process.env.OPENSHIFT_INTERNAL_PORT || 9778
        production:
            maxAge: false
            # maxAge: false

            hostname: process.env.OPENSHIFT_NODEJS_IP || '127.0.0.1'

            port: process.env.PORT || process.env.OPENSHIFT_NODEJS_PORT || process.env.OPENSHIFT_INTERNAL_PORT || 9778
        static:
            maxAge: 86400000
            # maxAge: false

            hostname: process.env.OPENSHIFT_NODEJS_IP || '127.0.0.1'
            # Listen to port 8082 on the development environment
            port: process.env.PORT || process.env.OPENSHIFT_NODEJS_PORT || process.env.OPENSHIFT_INTERNAL_PORT || 9778

    
    # =================================
    # DocPad Events

    # Here we can define handlers for events that DocPad fires
    # You can find a full listing of events on the DocPad Wiki

    events:

        # Server Extend
        # Used to add our own custom routes to the server before the docpad routes are added
        serverExtend: (opts) ->
            # Extract the server from the options
            {server} = opts
            docpad = @docpad
    
            # As we are now running in an event,
            # ensure we are using the latest copy of the docpad configuraiton
            # and fetch our urls from it
            latestConfig = docpad.getConfig()
            oldUrls = latestConfig.templateData.site.oldUrls or []
            newUrl = latestConfig.templateData.site.url

            # Redirect any requests accessing one of our sites oldUrls to the new site url
            server.use (req,res,next) ->
                if req.headers.host in oldUrls
                    res.redirect(newUrl+req.url, 301)
                else
                    next()



}

# Export our DocPad Configuration
module.exports = docpadConfig
