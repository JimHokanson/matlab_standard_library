classdef cmd_window < sl.obj.display_class
    %
    %   Class:
    %   sl.cmd_window
    %
    %   Run via:
    %   --------
    %   c = sl.ml.cmd_window.getInstance()
    %
    %   TODO:
    %   -----
    %   1) Can we get focus - for goDebug
    %   2) Most of the direct underlying calls should be wrapped to be 
    %   1 based instead of 0 based, since this is ending up being a
    %   mess to keep track of
    %
    %
    %   Very few methods have been exposed. Some interesting ones include:
    %   - getMouseListeners
    %   - getKeyListeners
    %   -
    
    %{
    getLineEndOffset - this seems to be pixel based not char based
    getLineOfOffset - goes from a char position to a line #
    getRows - doesn't seem to work
    %}
    
    properties (Hidden)
        h %com.mathworks.mde.cmdwin.CmdWin
        h_text %com.mathworks.mde.cmdwin.XCmdWndView
    end
    
    properties (Dependent)
        selection_start %In absolute characters, not row column
        %0 - to the left of the first character
        %1 - to the right of the first character
        
        selection_end %Same as selection_start
        
        line_count %Total # of lines in the command window
        has_focus %Whether the cursor is on the command window or not
        last_line_text
        
        cursor_line_text %
        %text up until the 
        
        line_text_up_to_cursor
        cursor_on_last_line %logical
        %Whether or not the cursor is on the last line
    end
    
    methods
        function value = get.selection_start(obj)
            value = obj.h_text.getSelectionStart();
        end
        function value = get.selection_end(obj)
            value = obj.h_text.getSelectionEnd();
        end
        function value = get.line_count(obj)
            value = obj.h_text.getLineCount();
        end
        function value = get.has_focus(obj)
            value = obj.h_text.hasFocus();
        end
        function value = get.last_line_text(obj)
            value = obj.getLineText(obj.line_count);
        end
        function value = get.cursor_line_text(obj)
           current_line_number_1b = obj.h_text.getLineOfOffset(obj.selection_start)+1; 
           value = obj.getLineText(current_line_number_1b);
        end
        function value = get.line_text_up_to_cursor(obj)
            line_number_0b = obj.h_text.getLineOfOffset(obj.selection_start);
            start_I = obj.h_text.getLineStartOffset(line_number_0b);
            end_I = obj.selection_start;
            n_chars = end_I - start_I;
            value = char(obj.h_text.getText(start_I,n_chars));
        end
        function value = get.cursor_on_last_line(obj)
            lc = obj.line_count;
            %NOTE: Original output is 0 based
            lo = obj.h_text.getLineOfOffset(obj.selection_start)+1;
            %fprintf(2,'%d %d\n',lc,lo)
            value = lo == lc;
        end
    end
    
    methods
        function text = getText(obj,start_char,end_char)
            %
            
            %   Internal function:
            %   getText() - 0 based
            %   returns carets ...
            
            n_chars = end_char-start_char+1;
            
            if nargin
                text = char(obj.h_text.getText(start_char-1,n_chars));
            else
                text = char(obj.h_text.getText());
            end
        end
        function line_text = getLineText(obj,line_number)
            %
            %
            
            %   Internal notes:
            %   getLineStartOffset => line number is 0 based
            
            %I think these 2 functions don't always work ...
            start_I = obj.h_text.getLineStartOffset(line_number-1);
            end_I = obj.h_text.getLineEndOffset(line_number-1);
            
            %How would one distinguish an empty line of text vs a line
            %with one character?
            %'' <= where's the start of this line? Which character?
            %calls return start_I==end_I
            %' ' <= start and end are the same, I think
            %but again, we can't look for start_I == end_I since
            %that is the same
            %
            %    Do we check for a newline as the output? Yes, let's go with
            %    that fix for now.
            
            n_chars = end_I-start_I;
            if n_chars == 0
                line_text = '';
            else
                line_text = char(obj.h_text.getText(start_I,n_chars));
                if double(line_text(end)) == 10
                    line_text(end) = [];
                end
            end
        end
    end
    
    methods (Access = private)
        function obj = cmd_window()
            %
            %   Launch via:
            %   -----------
            %   c = sl.ml.cmd_window.getInstance()
            
            %obj.h = com.mathworks.mde.cmdwin.cmdWinDocument.getInstance;
            obj.h = com.mathworks.mde.cmdwin.CmdWin.getInstance;
            obj.h_text = h__getTextReference(obj.h);
            
        end
    end
    
    methods (Static)
        function output = getInstance()
            %x Access method for singleton
            persistent local_obj
            if isempty(local_obj)
                local_obj = sl.ml.cmd_window;
            end
            output = local_obj;
        end
    end
end

%TODO: We should wrap h_text with methods so that everything is 1 based
% function h__getLineStartOffset()
%
% end

function h_text = h__getTextReference(h_cmd)
%
%
%   Code based on:
%   http://www.mathworks.com/matlabcentral/fileexchange/31438-command-window-text


cmd_window_components = get(h_cmd,'Components');
sub_components =get(cmd_window_components(1),'Components');
% java.awt.Component[]:
%     [javax.swing.JViewport            ]
%     [javax.swing.JScrollPane$ScrollBar]
%     [javax.swing.JScrollPane$ScrollBar]
sub_sub_components =get(sub_components(1),'Components');
% java.awt.Component[]:
%     [com.mathworks.mde.cmdwin.XCmdWndView]

h_text = sub_sub_components(1);

end

%{
methods(c.h_text)

Methods for class com.mathworks.mde.cmdwin.XCmdWndView:

action                              
add                                 
addAncestorListener                 
addCaretListener                    
addComponentListener                
addContainerListener                
addFocusListener                    
addHierarchyBoundsListener          
addHierarchyListener                
addIncSearchObserver                
addInputMethodListener              
addKeyListener                      
addKeymap                           
addMouseListener                    
addMouseMotionListener              
addMouseWheelListener               
addNotify                           
addPropertyChangeListener           
addVetoableChangeListener           
append                              
applyComponentOrientation           
areFocusTraversalKeysSet            
autoscroll                          
bounds                              
checkImage                          
clearSearch                         
computeVisibleRect                  
contains                            
copy                                
countComponents                     
createImage                         
createPopupMenu                     
createToolTip                       
createVolatileImage                 
cut                                 
deliverEvent                        
disable                             
dispatchEvent                       
doLayout                            
enable                              
enableInputMethods                  
endIncSearch                        
endIncSearchMoveCaret               
equals                              
find                                
findComponentAt                     
firePropertyChange                  
getAccessibleContext                
getActionForKeyStroke               
getActionMap                        
getActions                          
getAfterPromptPoint                 
getAlignmentX                       
getAlignmentY                       
getAncestorListeners                
getAutoscrollInsets                 
getAutoscrolls                      
getBackground                       
getBaseline                         
getBaselineResizeBehavior           
getBorder                           
getBounds                           
getCaret                            
getCaretColor                       
getCaretListeners                   
getCaretPosition                    
getClass                            
getClientProperty                   
getColorModel                       
getColumns                          
getComponent                        
getComponentAt                      
getComponentCount                   
getComponentListeners               
getComponentOrientation             
getComponentPopupMenu               
getComponentZOrder                  
getComponents                       
getConditionForKeyStroke            
getContainerListeners               
getCursor                           
getDebugGraphicsOptions             
getDefaultLocale                    
getDisabledTextColor                
getDocument                         
getDragEnabled                      
getDropLocation                     
getDropMode                         
getDropTarget                       
getFindClient                       
getFocusAccelerator                 
getFocusCycleRootAncestor           
getFocusListeners                   
getFocusTraversalKeys               
getFocusTraversalKeysEnabled        
getFocusTraversalPolicy             
getFont                             
getFontMetrics                      
getForeground                       
getGraphics                         
getGraphicsConfiguration            
getHeight                           
getHierarchyBoundsListeners         
getHierarchyListeners               
getHighlighter                      
getIgnoreRepaint                    
getInheritsPopupMenu                
getInputContext                     
getInputMap                         
getInputMethodListeners             
getInputMethodRequests              
getInputVerifier                    
getInsets                           
getInstance                         
getKeyListeners                     
getKeymap                           
getLastActiveComponent              
getLastKeyStrokePressed             
getLayout                           
getLineCount                        
getLineEndOffset                    
getLineOfOffset                     
getLineStartOffset                  
getLineWrap                         
getListeners                        
getLocale                           
getLocation                         
getLocationOnScreen                 
getMacSupport                       
getMargin                           
getMaximumSize                      
getMinimumSize                      
getMouseListeners                   
getMouseMotionListeners             
getMousePosition                    
getMouseWheelListeners              
getName                             
getNavigationFilter                 
getNextFocusableComponent           
getParent                           
getPeer                             
getPopupLocation                    
getPreferredScrollableViewportSize  
getPreferredSize                    
getPrintable                        
getPropertyChangeListeners          
getRegisteredKeyStrokes             
getRootPane                         
getRows                             
getScrollPane                       
getScrollableBlockIncrement         
getScrollableTracksViewportHeight   
getScrollableTracksViewportWidth    
getScrollableUnitIncrement          
getSelectedText                     
getSelectedTextColor                
getSelectionColor                   
getSelectionEnd                     
getSelectionStart                   
getSize                             
getSpaceBelowPrompt                 
getTabSize                          
getText                             
getToolTipLocation                  
getToolTipText                      
getToolkit                          
getTopLevelAncestor                 
getTransferHandler                  
getTreeLock                         
getUI                               
getUIClassID                        
getVerifyInputWhenFocusTarget       
getVetoableChangeListeners          
getVisibleRect                      
getWidth                            
getWrapStyleWord                    
getX                                
getY                                
gotFocus                            
grabFocus                           
handleEvent                         
hasFocus                            
hashCode                            
hide                                
imageUpdate                         
incSearch                           
incSearchEOL                        
incSearchNextWord                   
insert                              
insets                              
inside                              
invalidate                          
isAncestorOf                        
isBackgroundSet                     
isCursorSet                         
isDisplayable                       
isDoubleBuffered                    
isEditable                          
isEnabled                           
isFocusCycleRoot                    
isFocusOwner                        
isFocusTraversable                  
isFocusTraversalPolicyProvider      
isFocusTraversalPolicySet           
isFocusable                         
isFontSet                           
isForegroundSet                     
isLightweight                       
isLightweightComponent              
isManagingFocus                     
isMaximumSizeSet                    
isMinimumSizeSet                    
isOpaque                            
isOptimizedDrawingEnabled           
isPaintingForPrint                  
isPaintingTile                      
isPreferredSizeSet                  
isRequestFocusEnabled               
isShowing                           
isValid                             
isValidateRoot                      
isVisible                           
keyDown                             
keyUp                               
layout                              
list                                
loadKeymap                          
locate                              
location                            
lostFocus                           
minimumSize                         
modelToView                         
mouseDown                           
mouseDrag                           
mouseEnter                          
mouseExit                           
mouseMove                           
mouseUp                             
move                                
moveCaretPosition                   
nextFocus                           
notify                              
notifyAll                           
paint                               
paintAll                            
paintComponents                     
paintImmediately                    
paste                               
popPrompt                           
postEvent                           
preferredSize                       
prepareImage                        
print                               
printAll                            
printComponents                     
pushPrompt                          
putClientProperty                   
read                                
registerKeyboardAction              
remove                              
removeAll                           
removeAncestorListener              
removeCaretListener                 
removeComponentListener             
removeContainerListener             
removeFocusListener                 
removeHierarchyBoundsListener       
removeHierarchyListener             
removeIncSearchObserver             
removeInputMethodListener           
removeKeyListener                   
removeKeymap                        
removeMouseListener                 
removeMouseMotionListener           
removeMouseWheelListener            
removeNotify                        
removePropertyChangeListener        
removeVetoableChangeListener        
repaint                             
replaceRange                        
replaceSelection                    
requestDefaultFocus                 
requestFocus                        
requestFocusInWindow                
resetKeyboardActions                
reshape                             
resize                              
revalidate                          
scrollRectToVisible                 
scrollToBottom                      
select                              
selectAll                           
setActionMap                        
setAlignmentX                       
setAlignmentY                       
setAutoscrolls                      
setBackground                       
setBorder                           
setBounds                           
setCaret                            
setCaretColor                       
setCaretPosition                    
setColumns                          
setComponentOrientation             
setComponentPopupMenu               
setComponentZOrder                  
setCursor                           
setDebugGraphicsOptions             
setDefaultLocale                    
setDisabledTextColor                
setDocument                         
setDoubleBuffered                   
setDragEnabled                      
setDropMode                         
setDropTarget                       
setEditable                         
setEnabled                          
setFocusAccelerator                 
setFocusCycleRoot                   
setFocusTraversalKeys               
setFocusTraversalKeysEnabled        
setFocusTraversalPolicy             
setFocusTraversalPolicyProvider     
setFocusable                        
setFont                             
setForeground                       
setHighlighter                      
setIgnoreRepaint                    
setInheritsPopupMenu                
setInputMap                         
setInputVerifier                    
setKeymap                           
setLayout                           
setLineWrap                         
setLocale                           
setLocation                         
setMargin                           
setMaximumSize                      
setMinimumSize                      
setName                             
setNavigationFilter                 
setNextFocusableComponent           
setOpaque                           
setPreferredSize                    
setRequestFocusEnabled              
setRows                             
setSelectedTextColor                
setSelectionColor                   
setSelectionEnd                     
setSelectionStart                   
setSize                             
setTabSize                          
setText                             
setToolTipText                      
setTransferHandler                  
setUI                               
setVerifyInputWhenFocusTarget       
setVisible                          
setWrapStyleWord                    
show                                
size                                
startIncSearch                      
stateChanged                        
toString                            
transferFocus                       
transferFocusBackward               
transferFocusDownCycle              
transferFocusUpCycle                
unregisterKeyboardAction            
update                              
updateActions                       
updateUI                            
validate                            
viewToModel                         
wait                                
write     
      
%}
