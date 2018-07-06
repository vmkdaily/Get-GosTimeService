    NAME
        Get-GosTimeService

    SYNOPSIS


    SYNTAX
        Get-GosTimeService [-ComputerName] <String[]> [[-Credential] <PSCredential>] [<CommonParameters>]

        Get-GosTimeService [[-Credential] <PSCredential>] [-InputList] <String> [<CommonParameters>]


    DESCRIPTION
        Gets the the Windows Time Service information from one or more running Windows operating systems using WinRM (PowerShell Remoting).
        Uses the words gos (as in guest operating system) but does not use PowerCLI. This is Windows only, but is great for vSphere admins
        to reach Windows guests and check time.


    PARAMETERS
        -ComputerName <String[]>
            String. One or more Windows targets.

            Required?                    true
            Position?                    1
            Default value
            Accept pipeline input?       false
            Accept wildcard characters?  false

        -Credential <PSCredential>
            PSCredential. The login to the Windows target. If not populated we use SSPI.

            Required?                    false
            Position?                    2
            Default value
            Accept pipeline input?       false
            Accept wildcard characters?  false

        -InputList <String>
            String. Optionally, enter the path to a server list.

            Required?                    true
            Position?                    1
            Default value
            Accept pipeline input?       false
            Accept wildcard characters?  false

        <CommonParameters>
            This cmdlet supports the common parameters: Verbose, Debug,
            ErrorAction, ErrorVariable, WarningAction, WarningVariable,
            OutBuffer, PipelineVariable, and OutVariable. For more information, see
            about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

    INPUTS

    OUTPUTS

    NOTES


            Script:  Get-GosTimeService.ps1
            Author:  Mike Nisk
