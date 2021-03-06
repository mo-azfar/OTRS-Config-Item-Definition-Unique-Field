##Just under the BLOCK OF # check, whether the feature to check for a unique name is enabled 
##and above the BLOCK OF # get the config option for the name regex checks
##add these code
		
	#############FOR CUSTOM FIELD UNIQUE CHECK##########################
	if (
            IsStringWithData( $Version->{Name} )
            && $ConfigObject->Get('ITSMConfigItem::UniqueField')
            )
        {
			
		#get current class name
		my $CurrentClass = $GeneralCatalogObject->ItemGet(
		ItemID => $ConfigItem->{ClassID},
		);
			
            	my @Mappings = @{ $ConfigObject->Get('ITSMConfigItem::UniqueFieldValue') };
            
            	foreach my $Mapping (@Mappings)
            	{ 
                	my($Class, $DefinitionField, $FieldNumber) = split(/::/, $Mapping, 3);
                	next if $Class ne $CurrentClass->{Name};
                	next if $FieldNumber ne 1;
                	my $CurrentUniqueValue = $Version->{XMLData}->[1]->{Version}->[1]->{$DefinitionField}->[$FieldNumber]->{Content};
                	next if $CurrentUniqueValue eq '';
                	
                	my $DuplicateFieldValues = $Kernel::OM->Get('Kernel::System::ITSMUniqueField')->UniqueFieldCheck(
                	    ConfigItemID => $ConfigItem->{ConfigItemID},
                	    FieldName    => $DefinitionField,
                	    FieldValue   => $CurrentUniqueValue,
                	    ClassID      => $ConfigItem->{ClassID},
                	);
                	
                	
                	 # stop processing if the name is not unique
                	if ( IsArrayRefWithData($DuplicateFieldValues) ) 
                	{
    
			    $AllRequired = 0;
    
			    # build a string of all duplicate IDs
			    my $found_cid = join( ', ', @{$DuplicateFieldValues} );

			    return $LayoutObject->ErrorScreen(
				Message => $LayoutObject->{LanguageObject}
				->Translate( "The $DefinitionField: $CurrentUniqueValue is already in use by the ConfigItemID(s): $found_cid" ),
				Comment => Translatable('Please assign new value'),
				);
               		 }
     
            	}
	
	}
	#############END FOR CUSTOM FIELD UNIQUE CHECK##########################
		
		
