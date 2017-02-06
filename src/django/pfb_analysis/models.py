from __future__ import unicode_literals

import uuid

from django.db import models

from localflavor.us.models import USStateField

import us


class AnalysisJob(models.Model):

    class Status(object):
        CREATED = 'CREATED'
        IMPORTING = 'IMPORTING'
        BUILDING = 'BUILDING'
        CONNECTIVITY = 'CONNECTIVITY'
        METRICS = 'METRICS'
        EXPORTING = 'EXPORTING'
        COMPLETE = 'COMPLETE'
        ERROR = 'ERROR'

        CHOICES = (
            (CREATED, 'Created',),
            (IMPORTING, 'Importing Data',),
            (BUILDING, 'Building Network Graph',),
            (CONNECTIVITY, 'Calculating Connectivity',),
            (METRICS, 'Calculating Graph Metrics',),
            (EXPORTING, 'Exporting Results',),
            (COMPLETE, 'Complete',),
            (ERROR, 'Error',),
        )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    modified_at = models.DateTimeField(auto_now=True)

    status = models.CharField(choices=Status.CHOICES,
                              default=Status.CREATED,
                              max_length=12)

    state_abbrev = USStateField(help_text='The US state that the uploaded neighborhood is in')
    neighborhood_file = models.FileField(upload_to='/',
                                         help_text='A zipped shapefile boundary to run the ' +
                                                   'bike network analysis on')

    # TODO: Add once User/Organization models are in place
    # organization = models.ForeignKey()
    # uploaded_by = models.ForeignKey()

    @property
    def state(self):
        """ Return the us.states.State object associated with this boundary

        https://github.com/unitedstates/python-us

        """
        if not self._state:
            self._state = us.states.lookup(self.state_abbrev)
        return self._state

    def run(self):
        """ Run the analysis job

        TODO: Implement

        """
        pass
