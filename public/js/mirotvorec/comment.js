$(function(){
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
    /*
    * set hover actions
    */
    $('#dialog_link, ul#icons li').hover(
        function() { $(this).addClass('ui-state-hover'); },
        function() { $(this).removeClass('ui-state-hover'); }
    );
    /*
    * Dialog params
    * 
    * error dialog
    */
    $('#warning-load, #warning-update, #warning-delete').dialog({
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
    /*
    * edir dialog
    */
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
                            //console.log(res.text);
                            $('#comId'+res.c_id).html(res.text);
                            //$('#comId'+res.c_id).append(res.text);
                            $('#edit_com_form').attr('action', '');
                            $('#edit_com_area').val('');
                            $('#dialog').dialog('close');
                            ui.dialog('close');
                        } else if (res.status < 0) {
                            ui.dialog('close');
                            $('#warning-update').dialog('open');
                        }
                    },
                    type: 'post'
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
    /*
    * delete dialog
    */
    $('#del-comment').dialog({
        autoOpen: false,
        width: 620,
        draggable: false,
        resizable: false,
        modal: true,
        buttons: {
            "Удалить": function(event) {
                var ui = $(this);
                // console.log(ui);
                var id = $('#del-comment-id').attr('value');
                $.destroy('/delete/comment/' + id, function(res) {
                    if (res && res.status > 0) {
                        $('#comment_' + id).remove();
                        var col = $('.comm').length;
                        if (col == 0) $('.comment').after(comments);
                        $('#del-comment-id').attr('value', '');
                        $('#del-comment').dialog('close');
                    } else if (res && res.status < 0) {
                        $('#del-comment-id').attr('value', '');
                        $('#del-comment').dialog('close');
                        $('#warning-delete').dialog('open');
                    }
                });
            },
            "Отменить": function() {
                $('#del-comment-id').attr('value', '');
                $(this).dialog("close");
            }
        }
    });
    $('.del').click(function() {
        var dat = $(this).attr("id").split('_');
        var id = dat[1];
        $('#del-comment-id').attr('value', id);
        $('#del-comment').dialog('open');
        return false;
    });
    /*
    * end delete comment
    */
     
    /*
    * Dialog Link
    */
    $('.dialog_link').live('click', function(){
        var id = $(this).attr('id');
        var param = id.split('_');
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
                        $('#warning-load').dialog('open');
                    }
                }
            });
        return false;
    });
});