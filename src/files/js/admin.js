/*global window, document, CKEDITOR, $*/
CKEDITOR.replace('editor1', {
    height: 450
});

$(document).ready(function () {

    $('#permalink-host').text(window.location.protocol + "//" + window.location.hostname + "/");
    $("#edit-slug").click(function () {
        var $this = $(this);
        if ($this.attr('editing') != '1') {
            $this.text('Save').attr('editing', 1);
            var txt = $('#editable-slug').text();
            var input = $('<input class="editing" />').val(txt);
            $('#editable-slug').replaceWith(input);
        } else {
            $this.text('Edit').removeAttr('editing');
            var txt = $('input.editing').val();
            var div = $('<span id="editable-slug" title="Click to edit this part of the permalink" />').text(txt);

            $('input.editing').replaceWith(div);
        }
    });

    var tagInput = $(".tm-input").tagsManager();

    function getPost(slug) {
        $.ajax({
            url: '/admin/load/' + slug
        }).done(function (data) {
            $('#post-title').val(data.title);
            $('#editable-slug').text(data.slug).attr('data-slug',data.slug);
            CKEDITOR.instances['editor1'].setData(data.contentRenderedWithoutLayouts);
            extruder.closeMbExtruder();
            var tags = data.meta.tags;
            if (typeof tags === "string") {
                tags = tags.split(",");
            }
            for (var i = 0; i < tags.length; i++) {
                tagInput.tagsManager('pushTag', tags[i]);
            }

        });


    }

    var extruder = $("#extruderLeft").buildMbExtruder({
        position: "left",
        width: 300,
        extruderOpacity: 0.8,
        hidePanelsOnClose: true,
        accordionPanels: true,
        onExtOpen: function () {},
        onExtContentLoad: function () {
            $("#dash-posts li").click(function () {
                if (this.tagName === 'LI') {
                    var $this = $($(this).children('a:first'));
                    var slug = $this.attr('data-slug');
                    getPost(slug);

                }

            });

        },
        onExtClose: function () {},
        zIndex: 900
    });

    var slug = window.location.hash.replace('#','');
    
    if(slug){
        getPost(slug);
    }





});