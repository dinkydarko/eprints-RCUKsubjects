package EPrints::Plugin::Screen::EPMC::RCUKsubjects;

use EPrints::Plugin::Screen::EPMC;
@ISA = ( 'EPrints::Plugin::Screen::EPMC' );

use strict;
sub new
{
      my( $class, %params ) = @_;

      my $self = $class->SUPER::new( %params );

      $self->{actions} = [qw( enable disable )];
      $self->{disable} = 0; # always enabled, even in lib/plugins

      $self->{package_name} = "RCUKsubjects";

      return $self;
}

=item $screen->action_enable( [ SKIP_RELOAD ] )

Enable the L<EPrints::DataObj::EPM> for the current repository.

If SKIP_RELOAD is true will not reload the repository configuration.

=cut

sub action_enable
{
	my( $self, $skip_reload ) = @_;
	my $repo = $self->{repository};
	$self->SUPER::action_enable( $skip_reload );

        my $xmlz = $repo->xml;
        my $msg = $xmlz->create_document_fragment;

        $msg->appendChild($xmlz->create_text_node('RCUK Subjects has been installed, to use this plugin you will need to (1) import the RCUKsubjects subject file and (2) configure your template if you want to be able to search for RCUK subjects from your EPrints homepage. Now refresh your views.)'));

        $self->{processor}->add_message('message',$msg);

	my $xml = '
<workflow xmlns="http://eprints.org/ep3/workflow" xmlns:epc="http://eprints.org/ep3/control">
        <stage name="subjects">
         <epc:if test="type = \'dataset\'">
        <component type="Field::Subject"><field ref="RCUKsubjects" required="yes" /></component>
        </epc:if>
        <component type="Field::Subject"><field ref="subjects" required="no" /></component>
        </stage>
</workflow>
';

	my $filename = $repo->config( "config_path" )."/workflows/eprint/default.xml";

	EPrints::XML::add_to_xml( $filename, $xml, $self->{package_name} );
      
	$self->reload_config if !$skip_reload;
}

=item $screen->action_disable( [ SKIP_RELOAD ] )

Disable the L<EPrints::DataObj::EPM> for the current repository.

If SKIP_RELOAD is true will not reload the repository configuration.

=cut

sub action_disable
{
      my( $self, $skip_reload ) = @_;

      $self->SUPER::action_disable( $skip_reload );
      my $repo = $self->{repository};

      my $filename = $repo->config( "config_path" )."/workflows/eprint/default.xml";
 
      EPrints::XML::remove_package_from_xml( $filename, $self->{package_name} );
      
      $self->reload_config if !$skip_reload;

}

1;

