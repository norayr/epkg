
program epkg;
 USES args, unixtools, SysUtils, Dos, StrUtils;
 //struct pkg {char * name; char * folder};
 TYPE pkg = RECORD
      name : STRING;
      folder : STRING;
      END;

 CONST pkgdbpath='/var/db/pkg';
 VAR s : STRING;
 PROCEDURE showhelp;
 BEGIN
 WriteLn ('epkg v 1.3, help info');
 WriteLn ('epkg is a program which aimed to emulate dpkg on gentoo');
 WriteLn ('it also accepts equery syntax');
 WriteLn;
 WriteLn ('List the names of all installed packages.');
 WriteLn ('dpkg like syntax           equery like syntax');
 WriteLn ('   epkg --list                 epkg all');
 WriteLn ('   epkg -l');
 
// WriteLn ('epkg all');
 WriteLn ;
 WriteLn ('List files owned by package');
 WriteLn ('dpkg like syntax           equery like syntax');
 WriteLn ('   epkg -L     packagename     epkg files packagename');
 WriteLn ('   epkg --list packagename');
 WriteLn ('packagename may be in form like "=cat-egory/packagename-version"');
 //WriteLn ('epkg files packagename');
 WriteLn;
 WriteLn ('examples:');
 WriteLn ('epkg files =x11-libs/gtk+-2.8.12');
 WriteLn ('epkg -L gtk+');
 WriteLn;
 WriteLn ('List packages owning file');
 WriteLn ('dpkg like syntax           equery like syntax');
 WriteLn ('   epkg -S filename            epkg belongs filename');
 WriteLn ('epkg --search filename');
 WriteLn ('full path may be used as "filename"');
 WriteLn ('examples');
 WriteLn ('epkg --search /usr/bin/make');
 WriteLn ('epkg belongs cat');
// WriteLn ('epkg belongs filename');
 WriteLn;
 WriteLn ('List packages depending on package');
 WriteLn ('only equery like syntax accepted');
 WriteLn ('epkg depends pkgspec');
 WriteLn;
 WriteLn ('List the names of the packages with useflag');
 WriteLn ('only equery like syntax accepted');
 WriteLn ('epkg hasuse useflag');
 WriteLn;
 WriteLn ('epkg -h or epkg --help - try to guess :)'); WriteLn;
 
 //WriteLn ('all - Shows the names of all installed packages.');
 //WriteLn ('files pkgspec - List files owned by the pkgspec.');
 //WriteLn ('belongs file - List packages owning file.');
 //WriteLn ('depends pkgsepc - List packages depending on pkgspec.');
 //WriteLn ('hasuse useflag - List the names of the packages with useflag.');  
 END {showhelp};

 //This function gets the dependency list by reading the *DEPEND file.
 //The str will be matched to the ~/DEPEND, ~/RDEPEND and ~/PDEPEND file
 //contents and if the contents have the str then the CATEGORY/PACKAGE is
 //shown as having the str as a dependency.
 //The str is the dependecy of CATEGORY/PACKAGE.
 PROCEDURE equery(action : STRING; str : STRING);
 VAR a,b : UnixTools.dynar;
 VAR DEPEND_FILES : UnixTools.dynar;
 i,j,k : INTEGER;
 USE,PKGUSE,IUSE : INTEGER;
 f : TextFile;
 s,sl,sn : STRING;
 Var ansiStr : AnsiString;
 ch : CHAR;
 q,w : INTEGER;
 BEGIN

  //Newly implemented
  //Implementation of hasuse(equery hasuse doc)
  IF action = 'hasuse' THEN BEGIN
     //Get /var/db/pkg/* dir list 
     a := unixtools.listdir(pkgdbpath, '*-*');
     FOR i := 0 TO (HIGH(a)-1) DO BEGIN
         //Form the path like /var/db/pkg/dep-portage
         s := pkgdbpath+'/'+a[i];
         //Get the list of subdirs at the path just formed 
         b := UnixTools.listdir(s, '*');
         //Loop equal to the number of subdirs at the path just formed
         FOR j := 0 TO (HIGH(b)-1) DO BEGIN

             USE:=0;
             PKGUSE:=0;
             IUSE:=0;

             sl := pkgdbpath+'/'+a[i]+'/'+b[j]+'/'+'USE';
      	     IF FileExists (sl) THEN BEGIN
                 Assign (f, sl); reset(f);
		 REPEAT
                     ReadLn (f,s);
		     //Sohail
                     AppendStr(ansiStr,s);
                 UNTIL EOF(f); 
                 IF StrUtils.AnsiContainsStr(ansiStr,str) THEN BEGIN
                     USE:=1;
                 END{if contains str};
                 ansiStr:='';
             END               
             ELSE BEGIN 
             //    WriteLn (' File ' + sl + ' does not exists'); 
             END{if file exits sl=USE};

             sl := pkgdbpath+'/'+a[i]+'/'+b[j]+'/'+'PKGUSE';
      	     IF FileExists (sl) THEN BEGIN
                 Assign (f, sl); reset(f);
		 REPEAT
                     ReadLn (f,s);
                     AppendStr(ansiStr,s);
                 UNTIL EOF(f); 
                 IF StrUtils.AnsiContainsStr(ansiStr,str) THEN BEGIN
                     PKGUSE:=1;
                 END{if contains str};
                 ansiStr:='';
             END               
             ELSE BEGIN 
             //    WriteLn (' File ' + sl + ' does not exists'); 
             END{if file exits sl=PKGUSE};





             sl := pkgdbpath+'/'+a[i]+'/'+b[j]+'/'+'IUSE';
      	     IF FileExists (sl) THEN BEGIN
                 Assign (f, sl); reset(f);
		 REPEAT
                     ReadLn (f,s);
                     AppendStr(ansiStr,s);
                 UNTIL EOF(f); 
                 IF StrUtils.AnsiContainsStr(ansiStr,str) THEN BEGIN
                     IUSE:=1;
                 END{if contains str};
                 ansiStr:='';
             END               
             ELSE BEGIN 
             //    WriteLn (' File ' + sl + ' does not exists'); 
             END{if file exits sl=IUSE};




             IF USE = 1 THEN BEGIN
                 AppendStr(ansiStr,'USE ');
             END{if contains str};
             IF PKGUSE = 1 THEN BEGIN
                 AppendStr(ansiStr,'PKGUSE ');
             END;
             IF IUSE = 1 THEN BEGIN
                 AppendStr(ansiStr,'IUSE ');
             END;
             IF (USE = 1) OR (PKGUSE = 1) OR (IUSE = 1) THEN BEGIN
                 WriteLn(a[i],'/',b[j],' ',ansiStr);                  
             END;
         END{for j};
     END{for i};      
  END{if action=hasuse}; //Implementation of hasuse ends here 
 
  //Newly implemented
  //Implementation of belongs(equery belongs genorphan)
  IF action = 'belongs' THEN BEGIN
     //Get /var/db/pkg/* dir list 
     a := unixtools.listdir(pkgdbpath, '*-*');
     FOR i := 0 TO (HIGH(a)-1) DO BEGIN
         //Form the path like /var/db/pkg/dep-portage
         s := pkgdbpath+'/'+a[i];
         //Get the list of subdirs at the path just formed 
         b := UnixTools.listdir(s, '*');
         //Loop equal to the number of subdirs at the path just formed
         FOR j := 0 TO (HIGH(b)-1) DO BEGIN
             sl := pkgdbpath+'/'+a[i]+'/'+b[j]+'/'+'CONTENTS';
      	     IF FileExists (sl) THEN BEGIN
                 Assign (f, sl); reset(f);
		 REPEAT
                     ReadLn (f,s);
                     IF (COPY(s,1,3) = 'obj') OR (COPY(s,1,3) = 'sym') THEN BEGIN
                         ansiStr := StrUtils.extractdelimited (2, s, [' ']);
		         //Soni
                         AppendStr(ansiStr,' ');
                         IF StrUtils.AnsiContainsStr(ansiStr,'/'+str+' ') THEN BEGIN
	                    WriteLn(a[i],'/',b[j],' --> ',ansiStr);
		         END{if contains str};
                     END{if copy};
                 UNTIL EOF(f); 
             END               
             ELSE BEGIN 
                 WriteLn (' File ' + sl + ' does not exists'); 
             END{if file exits sl};
         END{for j};
     END{for i};      
  END; //{if action=belongs}; //Implementation of belongs ends here
  
  //Expanded to cover the RDEPEND AND PDEPEND
  IF action = 'depends' THEN BEGIN
  {
  //Get all the subdirctories at /var/db/pkg/
  a := unixtools.listdir(pkgdbpath, '*-*');
  //Get the templates....
  //DEPEND_FILES := unixtools.listdir('/usr/local/epkg-templates', '*DEPEND');
  FOR i := 0 TO (HIGH(a)-1) DO BEGIN
  //The PATH to the subdirectories of /var/db/pkg/
  s := pkgdbpath+'/'+a[i];
  b := UnixTools.listdir(s, '*');
    FOR j := 0 TO (HIGH(b)-1) DO BEGIN
        FOR k := 0 TO (HIGH(DEPEND_FILES)-1) DO BEGIN
            sl := pkgdbpath+'/'+a[i]+'/'+b[j]+'/'+DEPEND_FILES[k];
	    IF FileExists (sl) THEN BEGIN
	       				    Assign(f, sl); Reset (f); q := 0;
	       					REPEAT
				            {ReadLn (f, sn);
					    IF StrUtils.AnsiContainsStr(sn,str) THEN BEGIN
					             WriteLn (a[i],'/',b[j]);

					             END{IF};}
				              Read (f,ch);
					      IF ch = '(' THEN INC(q);
					      IF ch = ')' THEN DEC(q);
					      IF (ch = '/') AND (q = 0) THEN BEGIN sn := '';
					                  FOR w := 1 TO LENGTH (str) DO BEGIN Read (f,ch); sn := sn + ch; END;
	                                                  IF sn = str THEN BEGIN WriteLn (a[i],'/',b[j]) END;
					           END{IF};
					    UNTIL EOF (f);
					    Close(f);
				    END{IF};
	    END;
        END{for k}; // my end
  END{FOR i};
  }
  //code from 1.1
  a := unixtools.listdir(pkgdbpath, '*-*');
  FOR i := 0 TO (HIGH(a)-1) DO BEGIN
  s := pkgdbpath+'/'+a[i];
  b := UnixTools.listdir(s, '*');
    FOR j := 0 TO (HIGH(b)-1) DO BEGIN
        sl := pkgdbpath+'/'+ a[i] + '/' + b[j]+ '/' + 'RDEPEND';
	IF FileExists (sl) THEN BEGIN
	     				Assign(f, sl); Reset (f); q := 0;
					   REPEAT
					    {ReadLn (f, sn);
					    IF StrUtils.AnsiContainsStr(sn,str) THEN BEGIN
					             WriteLn (a[i],'/',b[j]);
					    
					             END;}
				              Read (f,ch);
					      IF ch = '(' THEN INC(q);
					      IF ch = ')' THEN DEC(q);
					      IF (ch = '/') AND (q = 0) THEN BEGIN sn := '';
					                  FOR w := 1 TO LENGTH (str) DO BEGIN Read (f,ch); sn := sn + ch; END;
	                                                  IF sn = str THEN BEGIN WriteLn (a[i],'/',b[j]) END;
					           END{IF};
					    UNTIL EOF (f);
					    Close(f);
				    END{IF};
	END;
  END{FOR i};
//end of code from 1.1
 END{if depends};
 END {equery};

 PROCEDURE list;
 VAR a,b : UnixTools.dynar;
 s : STRING;
 i,j : INTEGER;
 BEGIN
 a := unixtools.listdir(pkgdbpath, '*-*');
 FOR i := 0 TO (HIGH(a)-1) DO BEGIN
 //WriteLn(a[i]);
 s := pkgdbpath+'/'+a[i];
 b := UnixTools.listdir(s, '*');
  FOR j := 0 TO (HIGH(b)-1) DO BEGIN WriteLn (b[j]) END;
 END{FOR i};

 END {list};

 // This procedure is executed when we use -L switch
 PROCEDURE ListContents (VAR p : pkg);
 VAR f : TextFile;
 s,sl : STRING;
 BEGIN
 //Prepare the PATH to the CONTENTS file.
 s := pkgdbpath + '/' + p.folder + '/' + p.name + '/' + 'CONTENTS';
 // See at the newely made PATH the CONTENTS file exists.
 IF FileExists(s) THEN 
    BEGIN 
    Assign (f, s); 
    reset(f);
 //Repeat the following block of code till the end of file is reached.
 //This block of code simply print out the contents of the CONTENTS file.
    REPEAT
       ReadLn (f,s);
       IF (COPY(s,1,3) = 'obj') OR (COPY(s,1,3) = 'sym') THEN BEGIN
              sl := StrUtils.extractdelimited (2, s, [' ']);
	      WriteLn (sl);
       END{IF};
    UNTIL EOF(f);
    END
   ELSE 
    BEGIN 
       WriteLn (' File ' + s + ' does not exists'); 
       halt 
    END
 END {ListContents};

 //This function updates the struct pkg.
 //After the updation it will call the ListContents function.
 PROCEDURE ListContent ( str : STRING);
 VAR q : BYTE;
 a,b : UnixTools.dynar;
 i,j : INTEGER;
 s,s1 : STRING;
 p : pkg;
 pkgs : ARRAY OF pkg;
 bool : BOOLEAN;
 ch : CHAR;
 BEGIN
 {FOR i := 1 TO LENGTH(str) DO BEGIN IF str[i]='/' THEN bool1 := TRUE END;}
    IF str[1]='=' THEN BEGIN
        i := StrUtils.PosEx('/',str);
 	p.folder := COPY (str,2,i-2);
	p.name := COPY (str,i+1,LENGTH(str)-i);
	ListContents(p);
	halt
	END{IF};
 q := 0;
 SetLength (pkgs,1);
  //Get the list of directories ar /var/db/pk/
  a := unixtools.listdir(pkgdbpath, '*-*');
  FOR i := 0 TO (HIGH(a)-1) DO BEGIN
  s := pkgdbpath+'/'+a[i];
  b := UnixTools.listdir(s, '*');
    FOR j := 0 TO (HIGH(b)-1) DO BEGIN
        IF COPY(b[j],1,LENGTH(str))=str THEN
	                            BEGIN
                                    //Finally get the category/package value
			            //pair.
                                    //Category.
				    pkgs[q].name := b[j];
                                    //Package.
				    pkgs[q].folder := a[i];
				    INC(q);
				    //Add one more element to array pkgs
                                    //For the next loop.
				    SetLength(pkgs,q+1);
				    END{IF};
	END;
  END{FOR i};
  IF q = 0 THEN WriteLn ('package ' + str + ' is not installed');

  IF q >=2 THEN BEGIN
   WriteLn ('There are ' + IntToStr(q) + ' packages with name ' + str + ' installed');
   FOR i := 0 TO (HIGH(pkgs)-1) DO BEGIN
     WriteLn (i+1,'   ',pkgs[i].folder+'/'+pkgs[i].name);

   END;
   bool := FALSE;
   REPEAT
   WriteLn; WriteLn ('Which of them do you want to list? (1-',q,')'); ReadLn(s); s1 := IntToStr(q); ch := s1[1]; IF s[1] IN ['1'..ch] THEN bool := TRUE;
   UNTIL bool = TRUE;
   ListContents(pkgs[StrToInt(s[1])-1]);
  END{IF};

  IF q = 1 THEN ListContents(pkgs[0]);

  END {ListContent};

 BEGIN
 IF args.isthereargs = FALSE then BEGIN showhelp; halt END;
 IF args.IsThere ('-h') THEN BEGIN showhelp; halt END;
 IF args.IsThere ('--help') THEN BEGIN showhelp; halt END;
 IF args.isThere ('all') OR args.IsThere ('--list') or args.IsThere('-l') THEN BEGIN list; halt END;
 //-L is now files, 
 IF args.isThere ('files') THEN BEGIN
			       //Call this function to get the value assigned
			       //to -L switch
                               s := args.ParamValue('files');
                               //Call this function to update the
                               //struct pkg;
			       ListContent(s); halt;
			       END;

 IF args.isThere ('-L') THEN BEGIN
			       //Call this function to get the value assigned
			       //to -L switch
                               s := args.ParamValue('-L');
                               //Call this function to update the
                               //struct pkg;
			       ListContent(s); halt;
			       END;

 IF args.isThere ('--listfiles') THEN BEGIN
			       //Call this function to get the value assigned
			       //to -L switch
                               s := args.ParamValue('--listfiles');
                               //Call this function to update the
                               //struct pkg;
			       ListContent(s); halt;
			       END;
 //Expanded implementation
 //query is now depends
 //now it'll read *DEPEND files
 IF args.isThere ('depends') THEN BEGIN
                            s := args.ParamValue('depends');
			    equery('depends',s);
			    halt
			    END;
 //for compatibility with previous versions, undocumented
 // ept-get uses this yet
 IF args.isThere ('query') THEN BEGIN
                            s := args.ParamValue('depends');
			    equery('query',s);
			    halt
			    END;
 //Newly implemented
 IF args.isThere ('belongs') THEN BEGIN
                            s := args.ParamValue('belongs');
			    equery('belongs',s);
			    halt
			    END;

 IF args.isThere ('-S') THEN BEGIN
                            s := args.ParamValue('belongs');
			    equery('belongs',s);
			    halt
			    END;

 IF args.isThere ('--search') THEN BEGIN
                            s := args.ParamValue('belongs');
			    equery('belongs',s);
			    halt
			    END;

  //Newly implemented
 IF args.isThere ('hasuse') THEN BEGIN
                            s := args.ParamValue('hasuse');
			    equery('hasuse',s);
			    halt
			    END;
 showhelp
 END {epkg}.

