
//検索処理
$(function(){
    $("#submit").click(function(){
    $.ajax({
        type: "POST",
        url: "/calculation_recipe",
        dataType: "text", //dataTypeをちゃんと指定する
        data: {
            name: $("#name").val(),
            num: $("#num").val()
        },
        
        success :function(json){
            
            console.log(json)//このjsonは変えても大丈夫
            const json_string = JSON.parse(json);//jsonから配列にパースする

            console.log(json_string)//確認
            var $name = $('<p />').append(json_string.name);
            var $calories = $('<p />').append(json_string.calories);
            var $sikibetu = json_string.sikibetu + ",";

            console.log($name)

            $('#result').append($name);
            $('#mon').append($calories);

            $('#keisann').append($sikibetu);
            

            
            
        },
        error :function(){
            alert(error)
        }
    })
    })
});

// $.ajax({
//   type: "POST",
//   url: "/ip001A_select_js",
//   dataType: "text", //dataTypeをちゃんと指定する
//   data: {
//     'name':$('#name').val(),
//     'num':$('#num').val()
//   }
// })
//ajaxリクエストが