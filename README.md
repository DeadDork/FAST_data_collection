FAST Data Collection
====================

A set of scripts that polishes bad email patient data into half-way decent retrospective safety research data.

Purpose
-------

The purpose of these scripts is to take years and years worth of daily patient update emails (collated into a couple of .mbox files), and distill, clean, and consolidate the patient data into one simple-to-analyze table. That said, the format of the source data has undergone extensive tweaking by clinicians over the years, bastardization from sloppy medical interns, etc., making the task herculean.

(No, not the slaying-the-hydra sort of herculean. There is nothing heroic about this project. Rather, it's a cleaning-the-Augean-stables sort of herculean. Take my word for it: getting good data from a bad source is a huge PITA. The only way to discover errors & exceptions is through trial and error--and there are *a lot* of errors & exceptions to be discovered thanks to 5 years worth of poor data collection methods.)

(In fact, working out the data collection rules involved so much trial & error that I ended up learning about version control systems, git in particular, and ultimately GitHub in order to control the mess the project versions made of my file system.)

(Anyhooooo...)

These scripts take the error-full, irregularly formatted email data and run it through a number of heavily-tested functions that polish the rough source into decent research data.

Apologia
--------

The repo name is very misleading. This project is not about collecting data quickly. Rather it is about generating data for a one-off research project called FAST. The research in question is a safety study I am conducting at a medical clinic to investigate the relative safety of a number of different diet treatments. One of these is water-only fasting--which is how the study got the horrible acronym FAST.

Also, the project was put on the back-burner for a couple of months while I was tasked with transferring patient data from the clinic's old electronic medical record system to the new one. This project is far from finished.

Finally, even after I finish polishing this project, it will be an ugly mess. It is not elegant, nor is it doing anything particularly useful besides the one-time data generation and serving as a reference for the review board. It is certainly not an example of text mining, and calling it such is like calling my dreams of flying into space a rocket ship. All in all, I can't imagine this repo being of any use outside of the research project I'm working on. It's ugly ugly ugly. Which brings to mind Anna Bradstreet's poem "The Author to her Book":

> Thou ill-formed offspring of my feeble brain,
> 
> Who after birth did'st by my side remain,
> 
> Till snatcht from thence by friends, less wise than true,
> 
> Who thee abroad exposed to public view,
> 
> Made thee in rags, halting to th' press to trudge,
> 
> Where errors were not lessened (all may judge).
> 
> At thy return my blushing was not small,
> 
> My rambling brat (in print) should mother call.
> 
> I cast thee by as one unfit for light,
> 
> The visage was so irksome in my sight,
> 
> Yet being mine own, at length affection would
> 
> Thy blemishes amend, if so I could.
> 
> I washed thy face, but more defects I saw,
> 
> And rubbing off a spot, still made a flaw.
> 
> I stretcht thy joints to make thee even feet,
> 
> Yet still thou run'st more hobbling than is meet.
> 
> In better dress to trim thee was my mind,
> 
> But nought save home-spun cloth, i' th' house I find.
> 
> In this array, 'mongst vulgars may'st thou roam.
> 
> In critic's hands, beware thou dost not come,
> 
> And take thy way where yet thou art not known.
> 
> If for thy father askt, say, thou hadst none;
> 
> And for thy mother, she alas is poor,
> 
> Which caused her thus to send thee out of door.