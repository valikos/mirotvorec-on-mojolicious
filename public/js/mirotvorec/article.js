$(function(){
    // set hover actions
    $('#dialog_link, ul#icons li').hover(
        function() { $(this).addClass('ui-state-hover'); },
        function() { $(this).removeClass('ui-state-hover'); }
    );
    // dialog params
    // -- error dialog
    $('#warning').dialog({
        autoOpen: false,
        width: 620,
        draggable: false,
        resizable: false,
        modal: true,
        buttons: {
            "Закрыть": function() {
                $(this).dialog("close");
            }
        }
    });
    // -- edir dialog
    $('#dialog').dialog({
        autoOpen: false,
        width: 620,
        draggable: false,
        resizable: false,
        modal: true,
        buttons: {
            "Изменить": function(event) {
                var ui = $(this);
                var options = {
                    success: function(res){
                        if (res.status > 0) {
                            console.log(res.text);
                            $('#comId'+res.c_id).text(res.text);
                            $('#edit_com_form').attr('action', '');
                            $('#edit_com_area').val('');
                            $('#dialog').dialog('close');
                            ui.dialog('close');
                        }
                    },
                    type:          'post'
                };
                $('#edit_com_form').ajaxSubmit(options);
                //$('#edit_com_form').attr('action', '');
                //$('#edit_com_area').val('');
                //$(this).dialog("close");
            },
            "Отменить": function() {
                $('#edit_com_form').attr('action', '');
                $('#edit_com_area').val('');
                $(this).dialog("close");
            }
        }
    });
    // Dialog Link
    $('.dialog_link').live('click', function(){
        var id = $(this).attr('id');
        var param = id.split('_');;
        $.read('/get/comment/'+param[2],
            function(res){
                if (res) {
                    if (res.code == 1) {
                        $('#edit_com_form').attr('action', '/update/comment/' + res.data.c_id);
                        $('#edit_com_area').val(res.data.c_comment);
                        $('#dialog').dialog('open');
                    } else if (res.code == -1) {
                        $('#edit_com_form').attr('action', '');
                        $('#edit_com_area').val('');
                        $('#warning').dialog('open');
                    }
                }
            });
        return false;
    });
});


$(document).ready(function() {
    // Add markItUp! to your textarea in one line
    // $(‘textarea’).markItUp( { Settings }, { OptionalExtraSettings } );
    $('textarea.markItUpEditor').markItUp(myBbcodeSettings);
    $('textarea.markItUpEditor').focus();
    // You can add content from anywhere in your page
    // $.markItUp( { myBbcodeSettings } );
    var comment = '';
    $('.add').click(function() {
        comment = '';
        var user = '';
        comment = $( "#com" + $(this).attr("id") ).html();
        if ($( "#com" + $(this).attr("id") ).html()) {
            user = '=' + $( "#u" + $(this).attr("id") ).html();
        } else {
            user = '';
        }
        $.markItUp( 
            {    
                openWith   : '[quote' + user + ']',
                closeWith  : '[/quote]',
                placeHolder: comment
            }
        );
        return false;
    });

    $('.del').click(function() {
        var dat = $(this).attr("id").split('_');
        var id = dat[1];
        $.destroy('/delete/comment/' + id, function (res) {
            if (res && res.status > 0) {
                $('#comment_' + id).remove();
                var col = $('.comm').length;
                if (col == 0) $('.comment').after(comments);
            } else if (res && res.status < 0) {
                alert('Ошибка удаления комментария!!!');
            }
        });
        return false;
    });
});

var comments ='       <div class="table"> \
            <img src="/img/bg-th-left.gif" width="8" height="7" alt="" class="left" /> \
            <img src="/img/bg-th-right.gif" width="7" height="7" alt="" class="right" /> \
            <table class="listing form" cellpadding="0" cellspacing="0"> \
                <tr> \
                    <th class="full">Комментарии</th> \
                </tr> \
                <tr> \
                    <td class="left right">Данный материал не содержит комментариев</td> \
                </tr> \
            </table> \
        </div>';