# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
#check CI defintion field and value for uniqueness

package Kernel::System::ITSMUniqueField;

use strict;
use warnings;
use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::ITSMConfigItem'
);


sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object...
    my $Self = {};
    bless( $Self, $Type );

    $Self->{ConfigItemObject} = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

    return $Self;
}

=head2 UniqueFieldCheck()

This method checks all already existing config items, whether the given name does already exist
within the same config item class or among all classes, depending on the SysConfig value of
UniqueCIName::UniquenessCheckScope (Class or Global).

This method requires 4 parameters: 

"ConfigItemID"  is the ID of the ConfigItem, which is to be checked for uniqueness
"FieldName"     is the config item defintiion field name to be checked for uniqueness
"FieldValue"    is the config item definition field value to be checked for uniqueness
"ClassID"       is the ID of the config item's class

All parameters are mandatory.

my $DuplicateFieldNames = $Kernel::OM->Get('Kernel::System::ITSMUniqueField')->UniqueFieldCheck(
    ConfigItemID => '73'
    FieldName    => 'SerialNumber',
    FieldValue   => 'XT1060005',
    ClassID      => '22',
);

The given name is not unique
my $NameDuplicates = [ 5, 35, 48, ];    # IDs of ConfigItems with the same name

The given name is unique
my $NameDuplicates = [];

=cut

sub UniqueFieldCheck {
    my ( $Self, %Param ) = @_;

    # check for needed stuff
    for my $Needed (qw(ConfigItemID FieldName FieldValue ClassID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Missing parameter $Needed!",
            );
            return;
        }
    }

    # check ConfigItemID param for valid format
    if (
        !IsInteger( $Param{ConfigItemID} )
        && ( IsStringWithData( $Param{ConfigItemID} ) && $Param{ConfigItemID} ne 'NEW' )
        )
    {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "The ConfigItemID parameter needs to be an integer or 'NEW'",
        );
        return;
    }

    # check Field Name param for valid format
    if ( !IsStringWithData( $Param{FieldName} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "The FieldName parameter needs to be a string!",
        );
        return;
    }
    
     # check Field Name param for valid format
    if ( !IsStringWithData( $Param{FieldValue} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "The FieldValue parameter needs to be a string!",
        );
        return;
    }

    # check ClassID param for valid format
    if ( !IsInteger( $Param{ClassID} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "The ClassID parameter needs to be an integer",
        );
        return;
    }

    # get class list
    my $ClassList = $Kernel::OM->Get('Kernel::System::GeneralCatalog')->ItemList(
        Class => 'ITSM::ConfigItem::Class',
    );

    # check class list for validity
    if ( !IsHashRefWithData($ClassList) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Unable to retrieve a valid class list!",
        );
        return;
    }

    # get the class name from the class list
    my $Class = $ClassList->{ $Param{ClassID} };

    # check class for validity
    if ( !IsStringWithData($Class) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Unable to determine a config item class using the given ClassID!",
        );
        return;
    }
    elsif ( $Kernel::OM->Get('Kernel::Config')->{Debug} > 0 ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'debug',
            Message  => "Resolved ClassID $Param{ClassID} to class $Class",
        );
    }

    my %SearchCriteria;

    # add the config item class to the search criteria if the uniqueness scope is not global
    
    $SearchCriteria{ClassIDs} = [ $Param{ClassID} ];
    $SearchCriteria{What} = [ {	"[%]{'Version'}[%]{'".$Param{FieldName}."'}[%]{'Content'}" => [$Param{FieldValue}],	} ];

    # search for a config item matching the given name
    my $ConfigItem = $Self->{ConfigItemObject}->ConfigItemSearchExtended(%SearchCriteria);

    # remove the provided ConfigItemID from the results, otherwise the duplicate check would fail
    # because the ConfigItem itself is found as duplicate
    my @Duplicates = map {$_} grep { $_ ne $Param{ConfigItemID} } @{$ConfigItem};

    # if a config item was found, the given name is not unique
    # if no config item was found, the given name is unique

    # return the result of the config item search for duplicates
    return \@Duplicates;
}

1;

