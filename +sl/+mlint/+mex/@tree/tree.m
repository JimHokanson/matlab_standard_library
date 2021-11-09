classdef tree < sl.mlint
    %
    %   Class:
    %   sl.mlint.mex.tree
    %
    %   Parse tree
    %
    %   Status: May 15, 2020
    %   The basic framework is done. Needs to be wrapped by classes that
    %   use this information to do things.
    %
    %   
    

    %Function definition
    %   + attr
    %   - child
    %
    %   ml_indices = h__resolveIndices(obj,in)
    %   - FUNCTION
    %       + ETC
    %           + <NAME> ml_indices, OutVar TYPE flint  CX_FHEAD FULL
    %           - ETC
    %               + <NAME> h__resolveIndices, SubfunDef CX_FHEAD UP
    %               - <NAME> obj, InVar CX_FHEAD 1USE 2USE FULL
    %               - <NAME> in, InVar CX_FHEAD 1USE 2USE FULL
    
    
    %Format:
    %id: row/column I|    type | c1 | c2 | c3 | c4 | c5 | c6 | extra_info1
    %                          | extra_info2
    %
    %I  : character index (1 based)
    %c1 : first_attribute (0 based)
    %c2 : first_child (1 based)
    %c3 : next_sibling (0 based)
    %c4 : prev_sibling (0 based)
    %c5 : var_first_definition
    %c6 : var_next_usage
    %extra_info1 : (format varies)
    %     type : value
    %   -----------------
    %   <NAME> : name
    %        % : comment text
    %          : V=# of characters this encloses
    %
    %extra_info2 (format varies)
    %
    %   This Seems a lot more complicated, examples after each type are
    %   shown below
    %
    %   <NAME> :
    %        v1 v2   v3
    %       #1 10    ClassDef
    %       #2 20    ClassRef
    %       #3 5     PropDef
    %       #4 4     PropDef
    %       
    %       DOPE Dependent <= seen for attribute of properties
    %       #17 5       OutVar CX_FHEAD FULL
    %       #16 10      MethDef DOPE get  CX_FHEAD
    %       #18 3        InVar CX_FHEAD 1USE FULL
    %
    %   v1 : variable id
    %   v2 : variable length
    %   v3 : type
    %
    %   <INT>
    %       TYPE Flint   => I think this meaning floating-point integer 
    %
    %   <Expression> :
    %       CX_FBODY CX_EFF CX_TOPFUN
    %
    %   FUNCTION :
    %       CX_METHOD ClosedFunction
    %
    %   = :
    %       CX_FBODY CX_EFF
    %       
    
    %{
                           type      c1    c2    c3     c4    c5    c6    c7            
   0:   1/ 1    1|        CLASSDEF |   1 |   5 | 2825 |  -  |  -  |  -  |V=39929, 0/0
                                   |
   1:   1/ 1    1|         <CEXPR> |  -  |   2 |  -  |   0 |  -  |  -  |
                                   |
   2:   1/15   15|             '<' |   3 |   4 |  -  |   1 |  -  |  -  |
                                   |
   3:   1/10   10|          <NAME> |  -  |  -  |  -  |   2 |  -  |  -  | data
                                   | #1 4     ClassDef
   4:   1/17   17|          <NAME> |  -  |  -  |  -  |   2 |  -  |  -  | sl.obj.display_class
                                   | #2 20     ClassRef
   5:  87/ 5 2641|      PROPERTIES |  -  |   6 |  16 |   0 |  -  |  -  |V=3000
                                   |
   6:  88/ 9 2660|             '=' |   7 |  -  |   8 |   5 |  -  |  -  |
                                   |
   7:  88/ 9 2660|          <NAME> |  -  |  -  |  -  |   6 |  -  |  -  | d
                                   | #3 1      PropDef
   8:  95/ 9
    %}
    
    
    %{
    TYPES
    -----
    '% '
    '%{ '
    '''
    ''*' ' 
    ''+' '
    ''-' '
    ''.' '
    ''.*' '        }
    ''./' '        }
    ''/' '         }
    '':' '
    ''<' '
    ''=' '
    ''==' '
    ''UMINUS' '    }
    ''[' '         }
    ''{' '         }
    {''~' '         }
    {''~=' '        }
    {'(...) '       }
    {'<Anon ID> '   }
    {'<Anon> '      }
    {'<CALL> '      }
    {'<CEXPR> '     }
    {'<CHARVECTOR> '}
    {'<DOUBLE> '    }
    {'<Display> '   }
    {'<ETC> '       }
    {'<Expression> '}
    {'<FIELD> '     }
    {'<INT> '       }
    {'<Indexing> '  }
    {'<JOIN> '      }
    {'<NAME> '      }
    {'<ROW> '       }
    {'ATTR '        }
    {'ATTRIBUTES '  }
    {'CATCH '       }
    {'CELL '        }
    {'CLASSDEF '    }
    {'ELSE '        }
    {'ELSEIF '      }
    {'FOR '         }
    {'FUNCTION '    }
    {'IF '          }
    {'IFHEAD '      }
    {'METHODS '     }
    {'PROPERTIES '  }
    {'RETURN '      }
    {'TRY '         }
    
    %}
    
    properties
        line_numbers
        column_I
        
        char_I %[1 x n], Instead of a line number and column
        %index, this provides an absolute index into the string of the file
        %as to where the content starts.
        
        type %See examples above
        %e.g. <NAME>
        %     FUNCTION
        
        %Indices
        first_attribute
        first_child
        next_sibling
        prev_sibling
        var_first_definition
        var_next_usage
        
        parent
        %This initially was written so that we could get propdef values
        %quickly by searching a given parent
        %
        %although that is complicated as it seems the tree entry is:
        %
        %   - => child
        %   + => attribute
        %
        %   - properties
        %       - '='
        %           + <NAME> <- holds variable name
        %       
        %

        first_string
        second_string
        
        %Some more advanced processing
        %-----------------------------
        %method_def_I
        %property_def_I
    end
    
    methods
        function obj = tree(file_path)
            %
            %   obj = sl.mlint.mex.tree(file_path)
            %
            %   Example
            %   -------
            %   obj = sl.mlint.mex.tree(which('sl.plot.subplotter'));
            %
            %   obj = sl.mlint.mex.tree(which('editc'));
            
            obj.file_path      = file_path;
            %,'-m3' - no mlint
            %TODO: ?how to ignore errors???
            obj.raw_mex_string = mlintmex(file_path,'-tree','-m3');
            
            %0:   1/ 1    1|        CLASSDEF |   1 |   5 | 2825 |  -  |  -  |  -  |V=39929, 0/0
            
            %ASSUMPTION: 19 
            
            %text_scan breaks with '||'!
%             c = textscan(obj.raw_mex_string,...
%                 '%f: %f/%f %f|      %[^|]   | %f | %f | %f | %f | %f | %f | %[^\n] \n | %[^\n]',...
%                 'MultipleDelimsAsOne',true,'treatAsEmpty', {'-'});
%             

            %I tried | %f %[^\n] which didn't work
            c = textscan(obj.raw_mex_string,...
                '%f: %f/%f %f%19c %f | %f | %f | %f | %f | %f%[^\n] \n | %[^\n] \n',...
                'MultipleDelimsAsOne',true,'treatAsEmpty', {'-'});
            
%             c = textscan(obj.raw_mex_string,...
%                 '%f: %f/%f %f|%s|%f | %f | %f | %f | %f | %f | %[^\n]\n |%[^\n]\n',...
%                 'MultipleDelimsAsOne',true,'treatAsEmpty', {'-'});
            
            ids = c{1} + 1;
            
            max_id = max(ids);
            
            z_array = zeros(max_id,1);
            c_array = cell(max_id,1);
            obj.line_numbers = z_array;
            obj.line_numbers(ids) = c{2};
            
            obj.column_I = z_array;
            obj.column_I(ids) = c{3};
            
            obj.char_I = z_array;
            obj.char_I(ids) = c{4};
            
            obj.type = c_array;
            obj.type(ids) = strip(cellstr(c{5}(:,2:17)));
   
            obj.first_attribute = z_array;
            obj.first_attribute(ids) = c{6}+1;
            
            obj.first_child = z_array;
            obj.first_child(ids) = c{7} + 1;
            
            obj.next_sibling = z_array;
            obj.next_sibling(ids) = c{8} + 1;
            
            obj.prev_sibling = z_array;
            obj.prev_sibling(ids) = c{9} + 1;
            
            obj.var_first_definition = z_array;
            obj.var_first_definition(ids) = c{10} + 1;
            
            obj.var_next_usage = z_array;
            obj.var_next_usage(ids) = c{11} + 1;
            
            obj.first_string = c_array;
            %TODO: Remove anonymous ...
            obj.first_string(ids) = cellfun(@(x) strtrim(x(2:end)),c{12},'un',0);
            
            obj.second_string = c_array;
            obj.second_string(ids) = c{13};
            
            l_parents = z_array;
            l_parents(:) = -1; %Not set
            l_parents(1) = 0; %0 will mean root
           
            %Note, all attributes currently have no parent 
            
            %Basically as a fall back update 1
            %then we'll invalidate because 1 doesn't have a parent
            l_child = obj.first_child;
            child_mask = isnan(l_child);
            l_child(child_mask) = 1;
            
            l_next = obj.next_sibling;
            next_mask = isnan(l_next);
            l_next(next_mask) = 1;
            
            for i = 1:length(l_child)-1
                %in parent - set parent of first child
                l_parents(l_child(i)) = i;
                
                %child - set parent of next child as self parent
                l_parents(l_next(i)) = l_parents(i);
            end
            
            %Reset since likely overridden since l_next(i) and
            %l_child(i) will often be 1
            l_parents(1) = 0;
            
            obj.parent = l_parents;
            
            %TODO
            %-----------------
            %Do we want # of siblings?
            
            
            
            %How do we get parents ...
            
            %Set from the parent
            %--------------------
            %1) 
            %2) 

            
        end
        function s = getIndexStruct(obj,index)
            s = struct(...
                'line',obj.line_numbers(index),...
                'column',obj.column_I(index),...
                'char_I',obj.char_I(index),...
                'type',obj.type{index},...
                'first_attribute',obj.first_attribute(index),...
                'first_child',obj.first_child(index),...
                'next_sibling',obj.next_sibling(index),...
                'prev_sibling',obj.prev_sibling(index),...
                'parent',obj.parent(index),...
                'var_first_definition',obj.var_first_definition(index),...
                'var_next_usage',obj.var_next_usage(index),...
                'first_string',obj.first_string{index},...
                'second_string',obj.second_string{index});
        end
    end
    
end

%0.87 mex
%1.67 regexprep - yikes, would like to avoid this
%1.53 textscan
%1 second each for first and second string
