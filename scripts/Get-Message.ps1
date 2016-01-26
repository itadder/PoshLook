function Get-Message {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [AE.Net.Mail.ImapClient]$Session,

        [string]$From,
        [string]$To,
        [DateTime]$On,
        [DateTime]$After,
        [DateTime]$Before,
        [string]$Cc,
        [string]$Bcc,
        [string]$Subject,
        [string]$Text,
        [string]$Body,
        [string[]]$Label,
        [string]$FileName,

        [ValidateSet("Primary", "Personal", "Social", "Promotions", "Updates", "Forums")]
        [string]$Category,

        [switch]$Unread,
        [switch]$Read,
        [switch]$Starred,
        [switch]$Unstarred,
        [switch]$HasAttachment,
        [switch]$Answered,
        [switch]$Draft,
        [switch]$Undraft,
        [switch]$Prefetch
    )

    $imap = @()
    $xgm = @()

    if ($Unread) {
        $imap += "UNSEEN"
    } elseif ($Read) {
        $imap += "SEEN"
    }

    if ($Answered) {
        $imap += "ANSWERED"
    }

    if ($Draft) {
        $imap += "DRAFT"
    } elseif ($Undraft) {
        $imap += "UNDRAFT"
    }

    if ($Starred) {
        $imap += "FLAGGED"
    } elseif ($Unstarred) {
        $imap += "UNFLAGGED"
    }

    if ($On) {
        $imap += 'ON "' + $(GetRFC2060Date $After) + '"'
    }

    if ($From) {
        $imap += 'FROM "' + $From + '"'
    }

    if ($To) {
        $imap += 'TO "' + $To + '"'
    }

    if ($After) {
        $imap += 'AFTER "' + $(GetRFC2060Date $After) + '"'
    }

    if ($Before) {
        $imap += 'BEFORE "' + $(GetRFC2060Date $Before) + '"'
    }

    if ($Cc) {
        $imap += 'CC "' + $Cc + '"'
    }

    if ($Bcc) {
        $imap += 'BCC "' + $Bcc + '"'
    }

    if ($Text) {
        $imap += 'TEXT "' + $Text + '"'
    }

    if ($Body) {
        $imap += 'BODY "' + $Body + '"'
    }

    if ($Subject) {
        $imap += 'SUBJECT "' + $Subject + '"'
    }
    
    if ($Label) {
        $Label | ForEach-Object { $xgm += 'label:' + $_ }
    }

    if ($HasAttachment) {
        $xgm += 'has:attachment'
    }

    if ($FileName) {
        $xgm += 'filename:' + $FileName
    }

    if ($Category) {
        $xgm += 'category:' + $Category
    }

    if ($imap.Length -gt 0) {
        $criteria = ($imap -join ') (')
    }

    if ($xgm.Length -gt 0) {
        $gmcr = 'X-GM-RAW "' + ($xgm -join ' ') + '"'
        if ($imap.Length -gt 0) {
            $criteria = $criteria + ' (' + $gmcr + ')'
        } else {
            $criteria = $gmcr
        }
    }

    $result = $Session.Search('(' + $criteria + ')');
    $i = 1

    foreach ($item in $result) {
        $msg = $Session.GetMessage($item, !$Prefetch, $false)
        AddSessionTo $msg $Session
        Write-Progress -Activity "Gathering messages" -Status "Progress: $($i)/$($result.Count)" -PercentComplete ($i / $result.Count * 100) -Id 90017
        $i += 1
    }
}
