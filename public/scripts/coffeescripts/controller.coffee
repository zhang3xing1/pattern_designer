#every share data of single mission will be store here
define ->
	class Controller
		aGetRequest = (varName, callback, programName) ->
		  programName = "gui_example_test_2"  unless programName?
		  $.ajax
		    url: "get?var=" + varName + "&prog=" + programName
		    cache: false
		    success: (data) ->
		      callback data
		      return

		  return

		aSetRequest = (varName, newVarValue, callback, programName) ->
		  programName = "gui_example_test_2"  unless programName?
		  if newVarValue is ""
		    alert varName + "new value is Empty!"
		    return
		  $.ajax
		    url: "set?var=" + varName + "&prog=" + programName + "&value=" + newVarValue
		    cache: false
		    success: (data) ->
		      callback data, varName
		      return		

		# integer
		$("button.get." + "integer").click ->
		  aGetRequest "gui_" + "integer", (data) ->
		    $("label.get." + "integer").html data
		    $("#flash").html "Get " + varName + " done!"
		    return

		  return

		$("button.set." + "integer").click ->
		  setValue = $("input.set.integer").val()
		  aSetRequest "gui_" + "integer", setValue, (data, varName) ->
		    $("#flash").html "Set " + varName + " done!"
		    return

		  return
		      