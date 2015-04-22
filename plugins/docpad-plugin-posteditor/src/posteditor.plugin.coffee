# Export Plugin
module.exports = (BasePlugin) ->
    # Define Plugin
    safefs = require('safefs')
    path = require('path')
    class PostEditorPlugin extends BasePlugin
        # Plugin name
        name: 'posteditor'

        # Config
        config:
            tags: [],
            categories: []
            forceRelativePaths:['index.html.eco']
            
            
        


        
        
        
        
        
        
        forceRegenerate: ->
            console.log("In force regenerate")
            for path in @config.forceRelativePaths
                document = docpad.getCollection('documents').findOne({relativePath:path}).toJSON()
                fullpath = document.fullPath
                console.log("Force regenerate: "+fullpath)
                #txt = safefs.readFileSync(fullpath,'utf-8')
                #safefs.writeFileSync(fullpath,txt,'utf-8')

         
        # Use to extend the server with routes that will be triggered before the DocPad routes.
        serverExtend: (opts) ->
            # Extract the server from the options
            {server} = opts
            docpad = @docpad
            docpadCfg = docpad.getConfig()
            

            server.get /\/admin\/load\/[a-zA-z0-9\-]+/, (req,res,next) ->
                slug = req.url.split('/').pop()
                document = docpad.getCollection('posts').findOne({slug: slug}).toJSON()
                obj =
                    title: document.title
                    date: document.date
                    content: document.content
                    contentRenderedWithoutLayouts: document.contentRenderedWithoutLayouts
                    slug: document.slug
                    header: document.header
                    meta: document.meta
                    
                content = JSON.stringify(obj)
                res.setHeader('Content-Type', 'application/json')
                res.send(200, content)
                #next()
            #don't call next as the request stops here because we are serving the document

            server.post /\/admin\/save\/[a-zA-z0-9\-]+/, (req,res,next) ->

                if (req.body.content && req.body.origSlug)

                    slug = req.body.origSlug
                    document = docpad.getCollection('documents').findOne({slug:slug}).toJSON()

                    outFile = path.join(document.fullDirPath,document.basename+'.html.md')
                    documentAttributes =
                        content: req.body.content or document.content
                        meta: document.meta
                    documentAttributes.meta.title = req.body.title

                    meta = ""
                    for key, val of documentAttributes.meta
                        meta+= key+": "+val+"\r\n"
                    content = '---\r\n'+meta+'\r\n---\r\n'+documentAttributes.content
                    plugin = @

                    safefs.writeFile outFile, content, (err) ->
                        # Check
                        return next(err, document)  if err
                        # Log
                        docpad.log('info', "Updated file #{outFile} from request")
                        console.log("Force Regenerate")
                        setTimeout(() ->
                            console.log("DOIN THIS")
                            plugin.forceRegenerate()
                        ,5000)

                       
                     
                      
                    return res.json({title:documentAttributes.meta.title})
                else
                    return res.json({success:false})

            @
        

