#!/usr/bin/python 
# -*- coding:Utf-8 -*- 
def keynat(string):
    r'''A natural sort helper function for sort() and sorted()
    without using regular expressions or exceptions.

    >>> items = ('Z', 'a', '10th', '1st', '9')
    >>> sorted(items)
    ['10th', '1st', '9', 'Z', 'a']
    >>> sorted(items, key=keynat)
    ['1st', '9', '10th', 'a', 'Z']    
    '''
    it = type(1)
    r = []
    for c in string:
        if c.isdigit():
            d = int(c)
            if r and type( r[-1] ) == it: 
                r[-1] = r[-1] * 10 + d
            else: 
                r.append(d)
        else:
            r.append(c.lower())
    return r


f=open ('PlayOnLinux.lst','r')
w=open ('/tmp/pol.lst','w')
listTab = f.readlines()
listTab.sort(key=keynat)
i = 0
while (i < len(listTab)):
#	print listTab[i]
	w.write(listTab[i])
	i+=1
	
f.close()
w.close()
