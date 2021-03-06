//=========================================================================================
//=========================== Added by YangMing ===========================================
//=========================================================================================

//2011-04-27
macro __BlockIndent()
{
	var hwnd
	var sel
	var hbuf
	var fSelFile
	var szDir
	var fname
	var fbuf
	var i
	var sz
	var cmd
	var lnCnt

    hwnd = GetCurrentWnd()
	sel = GetWndSel (hwnd)
	hbuf = GetWndBuf (hwnd)
	fSelFile = GetBufName (hbuf)
	szDir = _GetDirName (fSelFile)

	//new a file the store the content selected temperorily
	_LogI(szDir)
	fname = _SINewTmpFile(szDir)
	fbuf = OpenBuf (fname)
	if (hNil == fbuf)
	{
		fbuf = NewBuf(fname)
		_Assert(fbuf == hNil)
	}
	else
	{
		ClearBuf (fbuf)
	}

	_LogI(sel)
	i = sel.lnFirst
	while (i <= sel.lnLast)
	{
		sz = GetBufLine (hbuf, i)
		AppendBufLine (fbuf, sz)
		i++
	}
	SaveBuf (fbuf)
	CloseBuf (fbuf)

	//run cmd to indent statements
	//cmd = "AStyle.exe --options=astylerc \"@fname@\""
	// Linux Kernel style
	//cmd = "clang-format.exe -style=\"{BasedOnStyle: LLVM, IndentWidth: 8, UseTab: Always, BreakBeforeBraces: Linux, AllowShortIfStatementsOnASingleLine: false, IndentCaseLabels: false}\" -i \"@fname@\""
	cmd = "clang-format.exe -style=file -i \"@fname@\""
	_LogI(cmd)
	if (0 != _RunCmdLine(cmd, _GetExternalBase() # "tool\\", True, 0))
		stop

	//handle the indented statements
	fbuf = OpenBuf (fname)
	if (hNil == fbuf)
		stop

	//clear current statements...
	lnCnt = sel.lnLast - sel.lnFirst + 1
	while (lnCnt--)
	{
		DelBufLine (hbuf, sel.lnFirst)
	}

	//paste the new statements
	lnCnt = GetBufLineCount (fbuf)
	while (lnCnt--)
	{
		sz = GetBufLine (fbuf, lnCnt)
		InsBufLine (hbuf, sel.lnFirst, sz)
	}
	SaveBuf (fbuf)
	CloseBuf (fbuf)
	_SIDelTmpFile(fname)

	return Nil
}

macro BlockIndent()
{
	//_InvokeMacro(__BlockIndent)
	_CheckIfPubEmExistsAndSWVersionRequirement()
	__BlockIndent()
	_LogShow()

	return Nil
}
