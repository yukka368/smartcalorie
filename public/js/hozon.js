$(function(){
    $("#hozon").click(function(){

        $ajax({
            type: "POST",
            url: "/create_recipe",
            dataType: "text",
            data: {
                dish: $(".dish").val(),
                data: $(".data").val(),
                recipe: $(".categry").val(),
                food_num: $("#keisann").val(),
                recipe: $("#recipe").val()             
            },
    
            success :function(){
    
            }
        })
    })
   
})