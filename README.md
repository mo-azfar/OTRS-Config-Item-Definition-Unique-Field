# OTRS-Config-Item-Definition-Unique-Field
- Enable check on unique field for Config Item definition  
- By default, unique field checking only available for CMDB Config Item Name only.  
- This modification will extend them to specific CMDB config item definition like SerialNumber, etc.  

1. Enable the function at System Configuration > ITSMConfigItem::UniqueField

2. Add the class and config item definiton name (which require unique check) at System Configuration > ITSMConfigItem::UniqueFieldValue.

  a)  Format : ClassName:DefinitionName::1  
  b)  Example below will check on class Computer (for SerialNumber) and also on class Hardware (for SerialNumber)  

      Computer::SerialNumber::1
      Hardware::SerialNumber::1
      
3. This function only for Config Item definition within the same class.  

4. You are required to modify the existing AgentITSMConfigItemEdit.pm file (do it at Custom directory please).  


Simulation => 

  2 Computer Config Item (C1 and C2) with different Serial Number
  [![download.png](https://i.postimg.cc/GmvG7yM0/download.png)](https://postimg.cc/87P7sjQw)

  Try updating C2 with the same serial number as C1  
  [![Capture.png](https://i.postimg.cc/DzRqx3sZ/Capture.png)](https://postimg.cc/jWQwj9M0)  
  
  Error after save  
  [![Capture2.png](https://i.postimg.cc/HWFvNFwf/Capture2.png)](https://postimg.cc/Wt67FWfn)  

