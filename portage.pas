unit portage;

interface

 VAR pkgdbpath='/var/db/pkg';
 PROCEDURE equery(action : STRING; str : STRING);
 PROCEDURE hasuse(str : STRING): TStringList;

implementation
uses Classes;
uses UnixTools;





 PROCEDURE hasuse(str : STRING): TStringList;
 VAR a, b : UnixTools.dynar;
     i, j : INTEGER;
     USE,PKGUSE,IUSE : INTEGER;
     f : TextFile;
     s,sl,sn : STRING;
     ansiStr : AnsiString;
     ch : CHAR;
     q,w : INTEGER;
     list : TStringList;
 BEGIN
     list := TStringList.Create;
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
                     s := s + ansiStr; //AppendStr(ansiStr,s);
                 UNTIL EOF(f); 
                 IF StrUtils.AnsiContainsStr(ansiStr,str) THEN BEGIN
                     USE:=1;
                 END{if contains str};
                 ansiStr:='';
		 close(f);
             END               
             ELSE BEGIN 
             //    WriteLn (' File ' + sl + ' does not exists'); 
             END{if file exits sl=USE};

             sl := pkgdbpath+'/'+a[i]+'/'+b[j]+'/'+'PKGUSE';
      	     IF FileExists (sl) THEN BEGIN
                 Assign (f, sl); reset(f);
		 REPEAT
                     ReadLn (f,s);
                     s := s + ansiStr; //AppendStr(ansiStr,s);
                 UNTIL EOF(f); 
                 IF StrUtils.AnsiContainsStr(ansiStr,str) THEN BEGIN
                     PKGUSE:=1;
                 END{if contains str};
                 ansiStr:='';
		 close(f);
             END               
             ELSE BEGIN 
             //    WriteLn (' File ' + sl + ' does not exists'); 
             END{if file exits sl=PKGUSE};

             sl := pkgdbpath+'/'+a[i]+'/'+b[j]+'/'+'IUSE';
      	     IF FileExists (sl) THEN BEGIN
                 Assign (f, sl); reset(f);
		 REPEAT
                     ReadLn (f,s);
                     s := s + ansiStr; //AppendStr(ansiStr,s);
                 UNTIL EOF(f); 
                 IF StrUtils.AnsiContainsStr(ansiStr,str) THEN BEGIN
                     IUSE:=1;
                 END{if contains str};
                 ansiStr:='';
		 close(f);
             END               
             ELSE BEGIN 
             //    WriteLn (' File ' + sl + ' does not exists'); 
             END{if file exits sl=IUSE};

             IF USE = 1 THEN BEGIN
                 ansiStr := ansiStr + 'USE '; //AppendStr(ansiStr,'USE ');
             END{if contains str};
             IF PKGUSE = 1 THEN BEGIN
                 ansiStr := ansiStr + 'PKGUSE ';//AppendStr(ansiStr,'PKGUSE ');
             END;
             IF IUSE = 1 THEN BEGIN
                 AppendStr(ansiStr,'IUSE ');
             END;
             IF (USE = 1) OR (PKGUSE = 1) OR (IUSE = 1) THEN BEGIN
                 //WriteLn(a[i],'/',b[j],' ',ansiStr);
		 list.Add (a[i] + '/' + b[j]);
             END;
         END{for j};
     END{for i};
     Result := list;
  END{if action=hasuse}; //Implementation of hasuse ends here 
 
 END //hasuse


 PROCEDURE belongs(str : STRING): TStringList;
 
  //Newly implemented
  //Implementation of belongs(equery belongs genorphan)

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
  END; //belongs
  


 PROCEDURE equery(action : STRING; str : STRING);
 VAR a,b : UnixTools.dynar;
 VAR //DEPEND_FILES : UnixTools.dynar;
 i,j : INTEGER;
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


 


end.
