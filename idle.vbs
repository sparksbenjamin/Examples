set wsc = CreateObject("WScript.Shell")
Do
  'Three minutes
    WScript.Sleep(3*60*1000)
    wsc.SendKeys("{NUMLOCK}")
	wsc.SendKeys("{NUMLOCK}")
Loop
