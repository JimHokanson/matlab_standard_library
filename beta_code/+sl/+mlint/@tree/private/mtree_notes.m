mtree notes

        %     -file:  the text argument is treated as a filename
        %     -comments:   comments are included in the tree
        %     -cell:  cell markers are included in the tree
[o.T,o.S,o.C] = mtreemex( text, opts{:} );

        T    % parse tree array
                 % column 1: kind of node
                 % column 2: index of left child
                 % column 3: index of right child
                 % column 4: index of next node
                 % column 5: position of node
                 % column 6: size of node
                 % column 7: symbol table index (V)R/
                 % column 8: string table index
                 % column 9: index of parent node
                 % column 10: setting node
                 % column 11: lefttreepos
                 % column 12: righttreepos
                 % column 13: true parent
                 % column 14: righttreeindex
                 % column 15: rightfullindex
        S    % symbol table
        C    % character strings
        IX   % index set (default is true for everything)
        n    % number of nodes
        m    % sum(IX)
        lnos % line number translation
        str  % input string that created the tree