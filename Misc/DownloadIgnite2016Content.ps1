#Script written by Vlad Catrinescu
#Visit my site www.absolute-sharepoint.com
#Twitter: @vladcatrinescu
#Originally Posted here: https://absolute-sharepoint.com/2016/10/the-ultimate-script-to-download-microsoft-ignite-2016-videos-and-slides

Param(
  [string]$keyword,[string]$session
)


######    Variables  #####

#Location - Preferably enter something not too long to not have filename problems! cut and paste them afterwards
$downloadlocation = "C:\Users\BenStegink\Downloads\MSIgniteContent"
#Ignite 2016 Videos RSS Feed
#[Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
try{ 
  $rss = (new-object net.webclient)
}
catch{
  $rss = (New-Object net.http.httpclient)
}
$video1 = ([xml]$rss.downloadstring("http://s.ch9.ms/events/ignite/2016/rss/mp4high"))
#$video1 = ($rss.GetStringAsync("http://s.ch9.ms/events/ignite/2016/rss/mp4high")).Result
$video2 = ([xml]$rss.downloadstring("http://s.ch9.ms/events/ignite/2016/rss/mp4high?page=2")) 
#$video2 = ($rss.GetStringAsync("http://s.ch9.ms/events/ignite/2016/rss/mp4high?page=2")).Result
#other qualities for the videos only. Uncomment below and delete the two previous lines to download Mid Quality videos
#$video1 = ([xml]$rss.downloadstring("http://s.ch9.ms/events/ignite/2016/rss/mp4"))
#$video2 = ([xml]$rss.downloadstring("http://s.ch9.ms/events/ignite/2016/rss/mp4?page=2"))
$slide1 = ([xml]$rss.downloadstring("http://s.ch9.ms/events/ignite/2016/rss/slides"))
#$slide1 = ($rss.GetStringAsync("http://s.ch9.ms/events/ignite/2016/rss/slides")).Result
slide2 = ([xml]$rss.downloadstring("http://s.ch9.ms/events/ignite/2016/rss/slides?page=2"))
#$slide2 = ($rss.GetStringAsync("http://s.ch9.ms/events/ignite/2016/rss/slides?page=2")).Result



#SCRIPT/ Functions  Do not touch below this line :)#
if (-not (Test-Path $downloadlocation)) { 
		Write-Host "Folder $fpath dosen't exist. Creating it..."  
		New-Item $downloadlocation -type directory | Out-Null
	}
set-location $downloadlocation

function CleanFilename($filename)
{
    return $filename.Replace(":", "-").Replace("?", "").Replace("/", "-").Replace("<", "").Replace("|", "").Replace('"',"").Replace("*","")
}

function DownloadSlides($filter,$videourl)
{
    try 
    {    
        $videourl.rss.channel.item | Where{($_.title -like “*$filter*”) -or ($_.link -like "*/$filter")} | 
        foreach {
	        $code = $_.comments.split("/") | select -last 1	   
	
	        # Grab the URL for the PPTX file
	        $urlpptx = New-Object System.Uri($_.enclosure.url)  
            $filepptx = $code + "-" + $_.creator + "-" + (CleanFileName($_.title))
	        $filepptx = $filepptx.substring(0, [System.Math]::Min(120, $filepptx.Length))
	        $filepptx = $filepptx.trim()
	        $filepptx = $filepptx + ".pptx" 
	        if ($code -ne "")
	        {
		         $folder = $code + " - " + (CleanFileName($_.title))
		         $folder = $folder.substring(0, [System.Math]::Min(100, $folder.Length))
		         $folder = $folder.trim()
	        }
	        else
	        {
		        $folder = "NoCodeSessions"
	        }
	
	        if (-not (Test-Path $folder)) { 
		        Write-Host "Folder $folder dosen't exist. Creating it..."  
		        New-Item $folder -type directory | Out-Null
	        }

	        # Make sure the PowerPoint file doesn't already exist
	        if (!(test-path "$downloadlocation\$folder\$filepptx"))     
	        { 	
		        # Echo out the  file that's being downloaded
		        write-host "Downloading slides: $filepptx"
		        #$wc = (New-Object System.Net.WebClient)  

		        # Download the MP4 file
		        #$wc.DownloadFile($urlpptx, "$downloadlocation\$filepptx")
                Start-BitsTransfer $urlpptx "$downloadlocation\$filepptx" -DisplayName $filepptx
		        mv $filepptx $folder 

	        }
            else
            {
   		        write-host "Slides exist: $filepptx"
            }
	    }

     }
    
    catch
    {
        $ErrorMessage = $_.Exception.Message
        Write-host "$ErrorMessage"
    }
}


function DownloadVideos($filter,$slideurl)
{
#download all the mp4
# Walk through each item in the feed 
$slideurl.rss.channel.item | Where{($_.title -like “*$filter*”) -or ($_.link -like "*/$filter*")} | foreach{   
	$code = $_.comments.split("/") | select -last 1	   
	
	# Grab the URL for the MP4 file
	$url = New-Object System.Uri($_.enclosure.url)  
	
	# Create the local file name for the MP4 download
	$file = $code + "-" + $_.creator + "-" + (CleanFileName($_.title))
	$file = $file.substring(0, [System.Math]::Min(120, $file.Length))
	$file = $file.trim()
	$file = $file + ".mp4"  
	
	if ($code -ne "")
	{
		 $folder = $code + " - " + (CleanFileName($_.title))
		 $folder = $folder.substring(0, [System.Math]::Min(100, $folder.Length))
		 $folder = $folder.trim()
	}
	else
	{
		$folder = "NoCodeSessions"
	}
	
	if (-not (Test-Path $folder)) { 
		Write-Host "Folder $folder) dosen't exist. Creating it..."  
		New-Item $folder -type directory | Out-Null
	}
	
	
	
	# Make sure the MP4 file doesn't already exist

	if (!(test-path "$folder\$file"))     
	{ 	
		# Echo out the  file that's being downloaded
		write-host "Downloading video: $file"
		#$wc = (New-Object System.Net.WebClient)  

		# Download the MP4 file
		Start-BitsTransfer $url "$downloadlocation\$file" -DisplayName $file
		mv $file $folder
	}
    else
    {
   		write-host "Video exists: $file"
    }

#text description from session
	$OutFile = New-Item -type file "$($downloadlocation)\$($Folder)\$($Code.trim()).txt" -Force  
    $Category = "" ; $Content = ""
    $_.category | foreach {$Category += $_ + ","}
    $Content = $_.title.trim() + "`r`n" + $_.creator + "`r`n" + $_.summary.trim() + "`r`n" + "`r`n" + $Category.Substring(0,$Category.Length -1)
   add-content $OutFile $Content
		
	}
}



if ($keyword)
{
    $keywords = $keyword.split(",")
    
    foreach ($k in $keywords)
    {
        $k.trim()
        Write-Host "You are now downloading the sessions with the keyword $k"
        DownloadSlides $k $slide1
        DownloadSlides $k $slide2
        DownloadVideos $k $video1
        DownloadVideos $k $video2
    }
}
elseif ($session)
{
    $sessions = $session.Split(",")
    
    foreach ($s in $sessions)
    {
        $s.trim()
        Write-Host "You are now downloading the session $s"
        DownloadSlides $s $slide1
        DownloadSlides $s $slide2
        DownloadVideos $s $video1
        DownloadVideos $s $video2
    }

}
else
{
    DownloadSlides " " $slide1
    DownloadSlides " " $slide2
    DownloadVideos " " $video1
    DownloadVideos " " $video2
}